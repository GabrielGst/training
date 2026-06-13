import { getTrackSummaries } from '@/lib/data';
import TrackCard from '@/components/TrackCard';

export default function TracksPage() {
  const tracks = getTrackSummaries();

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-white">All Tracks</h1>
        <p className="text-gray-400 mt-1">{tracks.length} tracks · Click a track to see modules</p>
      </div>

      <div className="grid md:grid-cols-2 gap-4">
        {tracks.map((track) => (
          <TrackCard key={track.id} track={track} />
        ))}
      </div>
    </div>
  );
}
