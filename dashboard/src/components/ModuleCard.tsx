'use client';

import { useState } from 'react';
import clsx from 'clsx';
import { TrainingModule, ModuleStatus } from '@/types';
import { updateModuleStatus, logHours } from '@/lib/actions';

const STATUS_LABELS: Record<ModuleStatus, string> = {
  not_started: 'Not started',
  in_progress: 'In progress',
  completed: 'Completed',
};

const STATUS_CYCLE: Record<ModuleStatus, ModuleStatus> = {
  not_started: 'in_progress',
  in_progress: 'completed',
  completed: 'not_started',
};

interface Props {
  module: TrainingModule;
  trackId: string;
}

export default function ModuleCard({ module: mod, trackId }: Props) {
  const [pending, setPending] = useState(false);
  const [hoursInput, setHoursInput] = useState('');

  async function handleStatusToggle() {
    setPending(true);
    await updateModuleStatus(trackId, mod.id, STATUS_CYCLE[mod.status]);
    setPending(false);
  }

  async function handleLogHours(e: React.FormEvent) {
    e.preventDefault();
    const h = parseFloat(hoursInput);
    if (!Number.isFinite(h) || h <= 0) return;
    setPending(true);
    await logHours(trackId, mod.id, h);
    setHoursInput('');
    setPending(false);
  }

  return (
    <div
      className={clsx(
        'card transition-opacity',
        pending && 'opacity-60 pointer-events-none',
      )}
    >
      <div className="flex items-center justify-between gap-3">
        <div className="min-w-0">
          <h4 className="text-sm font-medium text-white truncate">{mod.name}</h4>
          {mod.lastUpdated && (
            <p className="text-xs text-gray-500 mt-0.5">
              Updated {new Date(mod.lastUpdated).toLocaleDateString()}
            </p>
          )}
        </div>
        <div className="flex items-center gap-3 shrink-0">
          <span className="text-xs text-gray-400">{mod.hoursLogged}h</span>
          <button
            onClick={handleStatusToggle}
            className={clsx(
              'badge cursor-pointer select-none',
              mod.status === 'not_started' && 'badge-not-started hover:bg-gray-700',
              mod.status === 'in_progress' && 'badge-in-progress',
              mod.status === 'completed' && 'badge-completed',
            )}
          >
            {STATUS_LABELS[mod.status]}
          </button>
        </div>
      </div>

      <form onSubmit={handleLogHours} className="flex items-center gap-2 mt-3">
        <input
          type="number"
          min="0.25"
          max="24"
          step="0.25"
          placeholder="Hours"
          value={hoursInput}
          onChange={(e) => setHoursInput(e.target.value)}
          className="w-24 bg-gray-800 border border-gray-700 rounded-lg px-3 py-1.5
                     text-sm text-white placeholder-gray-500 focus:outline-none
                     focus:border-brand-500 transition-colors"
        />
        <button type="submit" className="btn-secondary text-xs py-1.5 px-3">
          + Log hours
        </button>
      </form>
    </div>
  );
}
