import { readProgress } from '@/lib/data';
import LogForm from '@/components/LogForm';

export default function LogPage() {
  const { tracks, dailyLog } = readProgress();
  const recentLog = dailyLog.slice(0, 20);

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-bold text-white">Daily Log</h1>
        <p className="text-gray-400 mt-1">Record what you worked on today</p>
      </div>

      <LogForm tracks={tracks} />

      {recentLog.length > 0 && (
        <div>
          <h2 className="text-lg font-semibold text-white mb-4">History</h2>
          <div className="card divide-y divide-gray-800">
            {recentLog.map((entry) => (
              <div key={entry.id} className="py-3">
                <div className="flex items-center justify-between">
                  <span className="text-sm font-medium text-white">{entry.moduleId}</span>
                  <span className="text-sm text-brand-500">{entry.hours}h</span>
                </div>
                <div className="flex items-center justify-between mt-0.5">
                  <span className="text-xs text-gray-500">{entry.trackId}</span>
                  <span className="text-xs text-gray-500">{entry.date}</span>
                </div>
                {entry.notes && (
                  <p className="text-xs text-gray-400 mt-1">{entry.notes}</p>
                )}
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
