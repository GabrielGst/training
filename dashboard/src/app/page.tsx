import { getGlobalProgress, getTrackSummaries, readProgress } from '@/lib/data';
import ProgressBar from '@/components/ProgressBar';
import TrackCard from '@/components/TrackCard';
import StreakCounter from '@/components/StreakCounter';

export default function OverviewPage() {
  const global = getGlobalProgress();
  const tracks = getTrackSummaries();
  const { streak, dailyLog } = readProgress();
  const recentLog = dailyLog.slice(0, 5);

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-bold text-white">Overview</h1>
        <p className="text-gray-400 mt-1">Full-Stack / AI Engineer Training</p>
      </div>

      {/* Global stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <div className="card text-center">
          <div className="text-3xl font-bold text-brand-500">{global.progressPercent}%</div>
          <div className="text-sm text-gray-400 mt-1">Overall</div>
        </div>
        <div className="card text-center">
          <div className="text-3xl font-bold text-white">
            {global.completedModules}
            <span className="text-gray-500 text-xl">/{global.totalModules}</span>
          </div>
          <div className="text-sm text-gray-400 mt-1">Modules</div>
        </div>
        <div className="card text-center">
          <div className="text-3xl font-bold text-white">{global.totalHours}</div>
          <div className="text-sm text-gray-400 mt-1">Hours logged</div>
        </div>
        <StreakCounter streak={streak} />
      </div>

      {/* Global progress bar */}
      <div className="card">
        <div className="flex justify-between text-sm text-gray-400 mb-2">
          <span>Global progress</span>
          <span>{global.completedModules} of {global.totalModules} modules</span>
        </div>
        <ProgressBar percent={global.progressPercent} size="lg" />
      </div>

      {/* Active tracks */}
      <div>
        <h2 className="text-lg font-semibold text-white mb-4">Tracks</h2>
        <div className="grid md:grid-cols-2 gap-4">
          {tracks.map((track) => (
            <TrackCard key={track.id} track={track} />
          ))}
        </div>
      </div>

      {/* Recent activity */}
      {recentLog.length > 0 && (
        <div>
          <h2 className="text-lg font-semibold text-white mb-4">Recent activity</h2>
          <div className="card divide-y divide-gray-800">
            {recentLog.map((entry) => (
              <div key={entry.id} className="py-3 flex items-center justify-between">
                <div>
                  <span className="text-sm text-white">{entry.moduleId}</span>
                  {entry.notes && (
                    <p className="text-xs text-gray-400 mt-0.5">{entry.notes}</p>
                  )}
                </div>
                <div className="text-right ml-4">
                  <div className="text-sm text-brand-500">{entry.hours}h</div>
                  <div className="text-xs text-gray-500">{entry.date}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
