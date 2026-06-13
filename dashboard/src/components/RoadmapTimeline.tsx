const PHASES = [
  {
    id: 1,
    title: 'Phase 1 — Foundations',
    weeks: 'Weeks 1–4',
    color: 'border-brand-500',
    dotColor: 'bg-brand-500',
    items: [
      'Git mastery & conventional commits',
      'Python (typed, tested, linted)',
      'TypeScript + Node fundamentals',
      'Docker & Docker Compose',
      'PostgreSQL basics',
      'Shell scripting',
    ],
    status: 'in_progress' as const,
  },
  {
    id: 2,
    title: 'Phase 2 — Core Tracks',
    weeks: 'Weeks 5–20',
    color: 'border-yellow-500',
    dotColor: 'bg-yellow-500',
    items: [
      '6 tracks running in parallel',
      '1 project minimum per module',
      'AI Engineer: PyTorch, TF, FastAPI',
      'Data Engineer: dbt, Airflow, PostgreSQL',
      'AI Agents: LangGraph, MCP, RAG',
      'Software Engineer: Next.js, k8s',
    ],
    status: 'pending' as const,
  },
  {
    id: 3,
    title: 'Phase 3 — Capstones',
    weeks: 'Weeks 21–28',
    color: 'border-green-500',
    dotColor: 'bg-green-500',
    items: [
      'ML Model Serving API (deployed)',
      'Full-stack Task App (deployed)',
      'End-to-End Data Platform',
      'Multi-Agent Research Assistant',
      'Remote GPU Training CLI',
      'Hybrid Quantum VQE',
    ],
    status: 'pending' as const,
  },
  {
    id: 4,
    title: 'Phase 4 — Portfolio & Job Prep',
    weeks: 'Weeks 29–32',
    color: 'border-purple-500',
    dotColor: 'bg-purple-500',
    items: [
      'Portfolio site deployed',
      'Case studies written',
      'Resume + GitHub profile polished',
      '50+ LeetCode mediums',
      'System design practice',
      'Mock technical interviews',
    ],
    status: 'pending' as const,
  },
];

const STATUS_STYLES = {
  completed: 'opacity-100',
  in_progress: 'opacity-100',
  pending: 'opacity-50',
};

export default function RoadmapTimeline() {
  return (
    <div className="relative">
      {/* Vertical connector line */}
      <div className="absolute left-4 top-6 bottom-6 w-0.5 bg-gray-800 md:left-6" />

      <div className="space-y-8">
        {PHASES.map((phase) => (
          <div
            key={phase.id}
            className={`relative pl-12 md:pl-16 ${STATUS_STYLES[phase.status]}`}
          >
            {/* Phase dot */}
            <div
              className={`absolute left-2 md:left-4 top-1.5 w-4 h-4 rounded-full border-2 border-gray-950 ${phase.dotColor}`}
            />

            <div className={`card border-l-4 ${phase.color}`}>
              <div className="flex items-baseline justify-between mb-3">
                <h3 className="font-bold text-white">{phase.title}</h3>
                <span className="text-xs text-gray-500 ml-2 shrink-0">{phase.weeks}</span>
              </div>
              <ul className="space-y-1">
                {phase.items.map((item) => (
                  <li key={item} className="text-sm text-gray-400 flex items-start gap-2">
                    <span className="text-gray-600 mt-0.5">—</span>
                    {item}
                  </li>
                ))}
              </ul>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
