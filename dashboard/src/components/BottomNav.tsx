import Link from 'next/link';

const NAV_ITEMS = [
  { href: '/', label: 'Overview', icon: '📊' },
  { href: '/tracks', label: 'Tracks', icon: '📚' },
  { href: '/roadmap', label: 'Roadmap', icon: '🗺️' },
  { href: '/log', label: 'Log', icon: '📝' },
];

export default function BottomNav() {
  return (
    <nav className="md:hidden fixed bottom-0 inset-x-0 bg-gray-900 border-t border-gray-800 flex">
      {NAV_ITEMS.map((item) => (
        <Link
          key={item.href}
          href={item.href}
          className="flex-1 flex flex-col items-center py-3 text-gray-400
                     hover:text-white transition-colors duration-150"
        >
          <span className="text-xl" aria-hidden="true">
            {item.icon}
          </span>
          <span className="text-xs mt-0.5">{item.label}</span>
        </Link>
      ))}
    </nav>
  );
}
