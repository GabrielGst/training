import Link from 'next/link';

const NAV_ITEMS = [
  { href: '/', label: 'Overview', icon: '📊' },
  { href: '/tracks', label: 'Tracks', icon: '📚' },
  { href: '/roadmap', label: 'Roadmap', icon: '🗺️' },
  { href: '/log', label: 'Daily Log', icon: '📝' },
];

export default function Sidebar() {
  return (
    <aside className="hidden md:flex flex-col fixed inset-y-0 left-0 w-56 bg-gray-900 border-r border-gray-800 px-4 py-6">
      <div className="mb-8">
        <h2 className="text-xs font-semibold text-gray-500 uppercase tracking-widest">
          Training
        </h2>
        <p className="text-sm text-white font-medium mt-1">Progress Tracker</p>
      </div>

      <nav className="space-y-1">
        {NAV_ITEMS.map((item) => (
          <Link
            key={item.href}
            href={item.href}
            className="flex items-center gap-3 px-3 py-2 rounded-lg text-sm text-gray-300
                       hover:text-white hover:bg-gray-800 transition-colors duration-150"
          >
            <span aria-hidden="true">{item.icon}</span>
            {item.label}
          </Link>
        ))}
      </nav>

      <div className="mt-auto">
        <div className="text-xs text-gray-600">
          <p>Target: Full-Stack / AI Eng</p>
          <p className="mt-0.5">Junior → Senior</p>
        </div>
      </div>
    </aside>
  );
}
