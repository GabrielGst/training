import { notFound } from 'next/navigation';
import { readProgress } from '@/lib/data';
import ProgressBar from '@/components/ProgressBar';
import ModuleCard from '@/components/ModuleCard';

interface Props {
  params: { slug: string };
}

export default function TrackDetailPage({ params }: Props) {
  const { tracks } = readProgress();
  const track = tracks.find((t) => t.id === params.slug);

  if (!track) notFound();

  const completed = track.modules.filter((m) => m.status === 'completed').length;
  const totalHours = track.modules.reduce((sum, m) => sum + m.hoursLogged, 0);
  const progressPercent =
    track.modules.length === 0
      ? 0
      : Math.round((completed / track.modules.length) * 100);

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-white capitalize">
          {track.name}
        </h1>
        <p className="text-gray-400 mt-1">
          {completed}/{track.modules.length} modules completed · {totalHours}h logged
        </p>
      </div>

      <div className="card">
        <div className="flex justify-between text-sm text-gray-400 mb-2">
          <span>Track progress</span>
          <span>{progressPercent}%</span>
        </div>
        <ProgressBar percent={progressPercent} size="md" />
      </div>

      <div className="space-y-3">
        {track.modules.map((mod) => (
          <ModuleCard key={mod.id} module={mod} trackId={track.id} />
        ))}
      </div>
    </div>
  );
}

export async function generateStaticParams() {
  const { tracks } = readProgress();
  return tracks.map((t) => ({ slug: t.id }));
}
