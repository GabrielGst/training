import type { Metadata } from 'next';
import './globals.css';
import Sidebar from '@/components/Sidebar';
import BottomNav from '@/components/BottomNav';

export const metadata: Metadata = {
  title: 'Training Dashboard',
  description: 'Personal full-stack / AI engineer training progress tracker',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="bg-gray-950 text-gray-100 min-h-screen">
        <div className="flex">
          <Sidebar />
          <main className="flex-1 md:ml-56 pb-20 md:pb-0">
            <div className="max-w-5xl mx-auto px-4 py-8">{children}</div>
          </main>
        </div>
        <BottomNav />
      </body>
    </html>
  );
}
