import Link from 'next/link';
import ProgressBar from '@/components/ProgressBar';
import { TrackSummary } from '@/types';

const TRACK_ICONS: Record<string, string> = {
  'ai-engineer': '🤖',
  'software-engineer': '💻',
  'data-engineer': '🗄️',
  'ai-agents': '🧠',
  'gpu-monitoring': '🎮',
  'hpc-quantum': '⚛️',
};

interface Props {
  track: TrackSummary;
}

export default function TrackCard({ track }: Props) {
  const icon = TRACK_ICONS[track.id] ?? '📚';
  const progressColor =
    track.progressPercent === 100
      ? 'green'
      : track.progressPercent > 0
        ? 'brand'
        : 'brand';

  return (
    <Link
      href={`/tracks/${track.id}`}
      className="card block hover:border-gray-700 hover:bg-gray-800/50 transition-colors duration-150"
    >
      <div className="flex items-start justify-between mb-3">
        <div className="flex items-center gap-2">
          <span className="text-2xl" aria-hidden="true">
            {icon}
          </span>
          <div>
            <h3 className="font-semibold text-white text-sm">{track.name}</h3>
            <p className="text-xs text-gray-400">
              {track.completedModules}/{track.totalModules} modules
              {track.inProgressModules > 0 && (
                <span className="text-yellow-400 ml-1">
                  · {track.inProgressModules} in progress
                </span>
              )}
            </p>
          </div>
        </div>
        <span className="text-lg font-bold text-brand-500">
          {track.progressPercent}%
        </span>
      </div>
      <ProgressBar percent={track.progressPercent} size="sm" color={progressColor} />
      <div className="mt-2 text-xs text-gray-500">{track.totalHours}h logged</div>
    </Link>
  );
}
