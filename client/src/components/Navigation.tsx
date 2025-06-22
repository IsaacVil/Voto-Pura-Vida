interface NavigationProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

export default function Navigation({ activeTab, setActiveTab }: NavigationProps) {
  const tabs = [
    { id: 'dashboard', label: 'Dashboard', icon: '📊' },
    { id: 'votaciones', label: 'Votaciones', icon: '🗳️' },
    { id: 'propuestas', label: 'Propuestas', icon: '📝' },
    { id: 'inversiones', label: 'Inversiones', icon: '💰' },
    { id: 'usuarios', label: 'Usuarios', icon: '👥' },
  ];

  return (
    <nav className="hidden md:flex space-x-6">
      {tabs.map((tab) => (
        <button
          key={tab.id}
          onClick={() => setActiveTab(tab.id)}
          className={`flex items-center space-x-2 px-4 py-2 rounded-lg transition-colors ${
            activeTab === tab.id 
              ? 'bg-green-600 text-white' 
              : 'text-gray-600 hover:bg-green-100 dark:text-gray-300 dark:hover:bg-gray-700'
          }`}
        >
          <span>{tab.icon}</span>
          <span>{tab.label}</span>
        </button>
      ))}
    </nav>
  );
}
