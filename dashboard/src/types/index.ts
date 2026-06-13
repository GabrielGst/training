export type ModuleStatus = 'not_started' | 'in_progress' | 'completed';

export interface TrainingModule {
  id: string;
  name: string;
  status: ModuleStatus;
  hoursLogged: number;
  lastUpdated: string | null;
  notes: string;
}

export interface Track {
  id: string;
  name: string;
  modules: TrainingModule[];
}

export interface DailyLogEntry {
  id: string;
  date: string;
  trackId: string;
  moduleId: string;
  hours: number;
  notes: string;
}

export interface Streak {
  current: number;
  longest: number;
  lastStudyDate: string | null;
}

export interface ProgressData {
  tracks: Track[];
  dailyLog: DailyLogEntry[];
  streak: Streak;
}

export interface TrackSummary {
  id: string;
  name: string;
  totalModules: number;
  completedModules: number;
  inProgressModules: number;
  totalHours: number;
  progressPercent: number;
}
