interface StatsCardProps {
  title: string;
  value: string | number;
  icon: React.ReactNode;
  color: 'blue' | 'green' | 'purple' | 'red' | 'yellow';
}

export default function StatsCard({ title, value, icon, color }: StatsCardProps) {
  const colorClasses = {
    blue: 'bg-blue-500 bg-opacity-20 text-blue-500',
    green: 'bg-green-500 bg-opacity-20 text-green-500',
    purple: 'bg-purple-500 bg-opacity-20 text-purple-500',
    red: 'bg-red-500 bg-opacity-20 text-red-500',
    yellow: 'bg-yellow-500 bg-opacity-20 text-yellow-500',
  };

  const valueColorClasses = {
    blue: 'text-blue-600',
    green: 'text-green-600',
    purple: 'text-purple-600',
    red: 'text-red-600',
    yellow: 'text-yellow-600',
  };

  return (
    <div className="bg-white dark:bg-gray-800 rounded-xl shadow-lg p-6 hover:shadow-xl transition-shadow">
      <div className="flex items-center">
        <div className={`p-3 rounded-full ${colorClasses[color]}`}>
          {icon}
        </div>
        <div className="ml-4">
          <h3 className="text-lg font-semibold text-gray-700 dark:text-gray-200">
            {title}
          </h3>
          <p className={`text-2xl font-bold ${valueColorClasses[color]}`}>
            {value}
          </p>
        </div>
      </div>
    </div>
  );
}
