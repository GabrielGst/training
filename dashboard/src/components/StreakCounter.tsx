import { Streak } from '@/types';

interface Props {
  streak: Streak;
}

export default function StreakCounter({ streak }: Props) {
  return (
    <div className="card text-center">
      <div className="text-3xl font-bold text-orange-400">
        {streak.current}
        <span className="text-lg ml-0.5">🔥</span>
      </div>
      <div className="text-sm text-gray-400 mt-1">Day streak</div>
      {streak.longest > 0 && (
        <div className="text-xs text-gray-500 mt-1">Best: {streak.longest}</div>
      )}
    </div>
  );
}
