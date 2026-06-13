import clsx from 'clsx';

interface Props {
  percent: number;
  size?: 'sm' | 'md' | 'lg';
  color?: 'brand' | 'green' | 'yellow';
}

export default function ProgressBar({
  percent,
  size = 'md',
  color = 'brand',
}: Props) {
  const clamped = Math.min(100, Math.max(0, percent));

  const trackHeight = {
    sm: 'h-1',
    md: 'h-2',
    lg: 'h-3',
  }[size];

  const fillColor = {
    brand: 'bg-brand-500',
    green: 'bg-green-500',
    yellow: 'bg-yellow-400',
  }[color];

  return (
    <div
      className={clsx('w-full bg-gray-800 rounded-full overflow-hidden', trackHeight)}
      role="progressbar"
      aria-valuenow={clamped}
      aria-valuemin={0}
      aria-valuemax={100}
    >
      <div
        className={clsx('h-full rounded-full transition-all duration-500', fillColor)}
        style={{ width: `${clamped}%` }}
      />
    </div>
  );
}
