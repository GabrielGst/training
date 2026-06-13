'use client';

import { useState } from 'react';
import { format } from 'date-fns';
import { Track } from '@/types';
import { addDailyLogEntry } from '@/lib/actions';

interface Props {
  tracks: Track[];
}

export default function LogForm({ tracks }: Props) {
  const [trackId, setTrackId] = useState(tracks[0]?.id ?? '');
  const [moduleId, setModuleId] = useState('');
  const [hours, setHours] = useState('');
  const [notes, setNotes] = useState('');
  const [pending, setPending] = useState(false);
  const [success, setSuccess] = useState(false);

  const selectedTrack = tracks.find((t) => t.id === trackId);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    if (!trackId || !moduleId || !hours) return;

    setPending(true);
    await addDailyLogEntry({
      date: format(new Date(), 'yyyy-MM-dd'),
      trackId,
      moduleId,
      hours: parseFloat(hours),
      notes,
    });
    setHours('');
    setNotes('');
    setPending(false);
    setSuccess(true);
    setTimeout(() => setSuccess(false), 3000);
  }

  return (
    <form onSubmit={handleSubmit} className="card space-y-4">
      <h2 className="font-semibold text-white">Log today&apos;s work</h2>

      <div className="grid sm:grid-cols-2 gap-4">
        <div>
          <label className="text-xs text-gray-400 mb-1 block">Track</label>
          <select
            value={trackId}
            onChange={(e) => {
              setTrackId(e.target.value);
              setModuleId('');
            }}
            className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2
                       text-sm text-white focus:outline-none focus:border-brand-500"
          >
            {tracks.map((t) => (
              <option key={t.id} value={t.id}>
                {t.name}
              </option>
            ))}
          </select>
        </div>

        <div>
          <label className="text-xs text-gray-400 mb-1 block">Module</label>
          <select
            value={moduleId}
            onChange={(e) => setModuleId(e.target.value)}
            className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2
                       text-sm text-white focus:outline-none focus:border-brand-500"
          >
            <option value="">Select module…</option>
            {selectedTrack?.modules.map((m) => (
              <option key={m.id} value={m.id}>
                {m.name}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div>
        <label className="text-xs text-gray-400 mb-1 block">Hours worked</label>
        <input
          type="number"
          min="0.25"
          max="24"
          step="0.25"
          placeholder="e.g. 1.5"
          value={hours}
          onChange={(e) => setHours(e.target.value)}
          className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2
                     text-sm text-white placeholder-gray-500 focus:outline-none
                     focus:border-brand-500"
        />
      </div>

      <div>
        <label className="text-xs text-gray-400 mb-1 block">Notes (optional)</label>
        <textarea
          placeholder="What did you work on? Key learnings? Blockers?"
          value={notes}
          onChange={(e) => setNotes(e.target.value)}
          rows={3}
          className="w-full bg-gray-800 border border-gray-700 rounded-lg px-3 py-2
                     text-sm text-white placeholder-gray-500 focus:outline-none
                     focus:border-brand-500 resize-none"
        />
      </div>

      <div className="flex items-center gap-3">
        <button
          type="submit"
          disabled={pending || !trackId || !moduleId || !hours}
          className="btn-primary"
        >
          {pending ? 'Saving…' : 'Log entry'}
        </button>
        {success && (
          <span className="text-sm text-green-400">Entry saved!</span>
        )}
      </div>
    </form>
  );
}
