'use server';

import { revalidatePath } from 'next/cache';
import { format } from 'date-fns';
import { readProgress, writeProgress } from './data';
import { DailyLogEntry, ModuleStatus, ProgressData } from '@/types';

export async function addDailyLogEntry(
  entry: Omit<DailyLogEntry, 'id'>,
): Promise<void> {
  const data = readProgress();
  const id = `${Date.now()}-${Math.random().toString(36).slice(2, 7)}`;
  data.dailyLog.unshift({ id, ...entry });
  updateStreak(data, entry.date);
  writeProgress(data);
  revalidatePath('/');
  revalidatePath('/log');
}

export async function updateModuleStatus(
  trackId: string,
  moduleId: string,
  status: ModuleStatus,
): Promise<void> {
  const data = readProgress();
  const mod = data.tracks.find((t) => t.id === trackId)?.modules.find((m) => m.id === moduleId);
  if (!mod) return;
  mod.status = status;
  mod.lastUpdated = format(new Date(), 'yyyy-MM-dd');
  writeProgress(data);
  revalidatePath('/');
  revalidatePath(`/tracks/${trackId}`);
}

export async function logHours(
  trackId: string,
  moduleId: string,
  hours: number,
): Promise<void> {
  const data = readProgress();
  const mod = data.tracks.find((t) => t.id === trackId)?.modules.find((m) => m.id === moduleId);
  if (!mod) return;
  mod.hoursLogged = Math.round((mod.hoursLogged + hours) * 100) / 100;
  mod.lastUpdated = format(new Date(), 'yyyy-MM-dd');
  writeProgress(data);
  revalidatePath('/');
  revalidatePath(`/tracks/${trackId}`);
}

function updateStreak(data: ProgressData, today: string): void {
  const { streak } = data;
  if (streak.lastStudyDate === today) return;
  const yesterday = format(new Date(Date.now() - 86_400_000), 'yyyy-MM-dd');
  streak.current = streak.lastStudyDate === yesterday ? streak.current + 1 : 1;
  streak.longest = Math.max(streak.longest, streak.current);
  streak.lastStudyDate = today;
}
