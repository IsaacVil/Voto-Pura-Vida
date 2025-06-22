'use client';

import { useState } from 'react';
import Link from 'next/link';

interface Proyecto {
  id: string;
  titulo: string;
  descripcion: string;
  categoria: string;
  creador: string;
  avatar: string;
  metaFinanciamiento: number;
  montoRecaudado: number;
  numeroInversores: number;
  fechaLanzamiento: string;
  fechaLimite: string;
  estado: 'activo' | 'financiado' | 'finalizado' | 'validacion';
  porcentajeRetorno: number;
  plazoRetorno: string;
  validadoPor: string[];
  riesgo: 'bajo' | 'medio' | 'alto';
  minInversion: number;
  documentos: string[];
  miInversion?: number;
}

export default function Crowdfunding() {
  const [filtro, setFiltro] = useState('todos');
  const [busqueda, setBusqueda] = useState('');
  const [ordenar, setOrdenar] = useState('reciente');

  // Datos de ejemplo
  const proyectos: Proyecto[] = [
    {
      id: '1',
      titulo: 'EcoLogistics CR - Delivery Sostenible',
      descripcion: 'Plataforma de delivery que utiliza únicamente vehículos eléctricos y bicicletas para reducir la huella de carbono en el Gran Área Metropolitana.',
      categoria: 'Tecnología Verde',
      creador: 'María Rodríguez',
      avatar: '👩‍💼',
      metaFinanciamiento: 75000000, // ₡75M
      montoRecaudado: 34500000, // ₡34.5M
      numeroInversores: 89,
      fechaLanzamiento: '2025-06-01',
      fechaLimite: '2025-07-15',
      estado: 'activo',
      porcentajeRetorno: 15,
      plazoRetorno: '24 meses',
      validadoPor: ['INCAE Business School', 'Cámara Costarricense de Tecnología'],
      riesgo: 'medio',
      minInversion: 50000,
      documentos: ['Plan de Negocio', 'Estudio de Mercado', 'Proyecciones Financieras']
    },
    {
      id: '2',
      titulo: 'AgriTech Solutions - IoT para Agricultura',
      descripcion: 'Sistema de sensores IoT para optimizar el riego y monitoreo de cultivos, aumentando la productividad agrícola de pequeños y medianos productores.',
      categoria: 'AgTech',
      creador: 'Carlos Vargas',
      avatar: '👨‍🌾',
      metaFinanciamiento: 45000000, // ₡45M
      montoRecaudado: 45000000, // ₡45M - FINANCIADO
      numeroInversores: 156,
      fechaLanzamiento: '2025-05-15',
      fechaLimite: '2025-06-30',
      estado: 'financiado',
      porcentajeRetorno: 18,
      plazoRetorno: '18 meses',
      validadoPor: ['INTA', 'Acelerador de Startups CENFOTEC'],
      riesgo: 'bajo',
      minInversion: 25000,
      documentos: ['Plan de Negocio', 'Validación Técnica', 'Cartas de Intención'],
      miInversion: 100000
    },
    {
      id: '3',
      titulo: 'TurismoVR - Experiencias Virtuales',
      descripcion: 'Plataforma de realidad virtual que permite a turistas internacionales experimentar destinos costarricenses desde sus casas, promoviendo el turismo futuro.',
      categoria: 'Turismo Tech',
      creador: 'Ana Jiménez',
      avatar: '👩‍💻',
      metaFinanciamiento: 60000000, // ₡60M
      montoRecaudado: 18750000, // ₡18.75M
      numeroInversores: 45,
      fechaLanzamiento: '2025-06-10',
      fechaLimite: '2025-08-01',
      estado: 'activo',
      porcentajeRetorno: 20,
      plazoRetorno: '30 meses',
      validadoPor: ['ICT', 'Universidad de Costa Rica'],
      riesgo: 'alto',
      minInversion: 75000,
      documentos: ['Prototipo Funcional', 'Estudio de Mercado Internacional', 'Plan de Marketing']
    },
    {
      id: '4',
      titulo: 'MediLink - Telemedicina Rural',
      descripcion: 'Aplicación móvil que conecta comunidades rurales con especialistas médicos a través de consultas virtuales, mejorando el acceso a la salud.',
      categoria: 'HealthTech',
      creador: 'Dr. Roberto Chen',
      avatar: '👨‍⚕️',
      metaFinanciamiento: 80000000, // ₡80M
      montoRecaudado: 0,
      numeroInversores: 0,
      fechaLanzamiento: '2025-06-18',
      fechaLimite: '2025-09-01',
      estado: 'validacion',
      porcentajeRetorno: 16,
      plazoRetorno: '36 meses',
      validadoPor: ['Colegio de Médicos', 'CCSS'],
      riesgo: 'medio',
      minInversion: 100000,
      documentos: ['Registro Sanitario', 'Protocolo Médico', 'Validación CCSS']
    }
  ];

  const proyectosFiltrados = proyectos.filter(proyecto => {
    const cumpleFiltro = filtro === 'todos' || proyecto.estado === filtro;
    const cumpleBusqueda = proyecto.titulo.toLowerCase().includes(busqueda.toLowerCase()) ||
                          proyecto.categoria.toLowerCase().includes(busqueda.toLowerCase());
    return cumpleFiltro && cumpleBusqueda;
  });

  const proyectosOrdenados = [...proyectosFiltrados].sort((a, b) => {
    switch (ordenar) {
      case 'reciente':
        return new Date(b.fechaLanzamiento).getTime() - new Date(a.fechaLanzamiento).getTime();
      case 'popular':
        return b.numeroInversores - a.numeroInversores;
      case 'progreso':
        return (b.montoRecaudado / b.metaFinanciamiento) - (a.montoRecaudado / a.metaFinanciamiento);
      default:
        return 0;
    }
  });

  const handleInvertir = (proyectoId: string) => {
    // Aquí se abriría un modal o navegaría a la página de inversión
    alert(`Redirigiendo a inversión en proyecto: ${proyectoId}`);
  };

  const formatCurrency = (amount: number) => {
    return `₡${(amount / 1000000).toFixed(1)}M`;
  };

  const getRiesgoColor = (riesgo: string) => {
    switch (riesgo) {
      case 'bajo': return 'text-green-600 bg-green-100';
      case 'medio': return 'text-yellow-600 bg-yellow-100';
      case 'alto': return 'text-red-600 bg-red-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  const getEstadoColor = (estado: string) => {
    switch (estado) {
      case 'activo': return 'text-green-600 bg-green-100';
      case 'financiado': return 'text-blue-600 bg-blue-100';
      case 'finalizado': return 'text-gray-600 bg-gray-100';
      case 'validacion': return 'text-yellow-600 bg-yellow-100';
      default: return 'text-gray-600 bg-gray-100';
    }
  };

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Navigation */}
      <nav className="bg-white shadow-sm border-b">
        <div className="container mx-auto px-6 py-4">
          <div className="flex justify-between items-center">
            <Link href="/" className="text-2xl font-bold text-green-600">
              Voto Pura Vida
            </Link>
            <div className="flex space-x-4">
              <Link href="/dashboard" className="text-gray-700 hover:text-green-600 px-4 py-2 rounded-lg transition-colors">
                Dashboard
              </Link>
              <Link href="/votaciones" className="text-gray-700 hover:text-green-600 px-4 py-2 rounded-lg transition-colors">
                Votaciones
              </Link>
              <Link href="/perfil" className="text-gray-700 hover:text-green-600 px-4 py-2 rounded-lg transition-colors">
                Mi Perfil
              </Link>
            </div>
          </div>
        </div>
      </nav>

      <div className="container mx-auto px-6 py-8">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-800 mb-4">Crowdfunding de Proyectos</h1>
          <p className="text-gray-600 max-w-2xl">
            Invierte en proyectos innovadores validados por expertos. Impulsa el emprendimiento 
            costarricense y obtén retornos atractivos con transparencia total.
          </p>
        </div>

        {/* Stats */}
        <div className="grid md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mr-4">
                <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-4m-5 0H9m0 0H5m4 0V9a1 1 0 011-1h4a1 1 0 011 1v4m-5 8H7a2 2 0 01-2-2V9a2 2 0 012-2h2m7 12h2a2 2 0 002-2V9a2 2 0 00-2-2h-2m-7 12V9a1 1 0 011-1h4a1 1 0 011 1v4" />
                </svg>
              </div>
              <div>
                <p className="text-2xl font-bold text-gray-800">4</p>
                <p className="text-gray-600 text-sm">Proyectos Activos</p>
              </div>
            </div>
          </div>
          
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center mr-4">
                <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                </svg>
              </div>
              <div>
                <p className="text-2xl font-bold text-gray-800">₡98.3M</p>
                <p className="text-gray-600 text-sm">Capital Recaudado</p>
              </div>
            </div>
          </div>
          
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center mr-4">
                <svg className="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              </div>
              <div>
                <p className="text-2xl font-bold text-gray-800">290</p>
                <p className="text-gray-600 text-sm">Inversores Activos</p>
              </div>
            </div>
          </div>
          
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center mr-4">
                <svg className="w-6 h-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" />
                </svg>
              </div>
              <div>
                <p className="text-2xl font-bold text-gray-800">17.2%</p>
                <p className="text-gray-600 text-sm">Retorno Promedio</p>
              </div>
            </div>
          </div>
        </div>

        {/* Filters */}
        <div className="bg-white rounded-lg shadow-sm p-6 mb-8">
          <div className="grid md:grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Filtrar por estado
              </label>
              <select
                value={filtro}
                onChange={(e) => setFiltro(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              >
                <option value="todos">Todos los proyectos</option>
                <option value="activo">Activos</option>
                <option value="financiado">Financiados</option>
                <option value="validacion">En validación</option>
                <option value="finalizado">Finalizados</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Buscar proyecto
              </label>
              <input
                type="text"
                value={busqueda}
                onChange={(e) => setBusqueda(e.target.value)}
                placeholder="Buscar por título o categoría..."
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Ordenar por
              </label>
              <select
                value={ordenar}
                onChange={(e) => setOrdenar(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              >
                <option value="reciente">Más recientes</option>
                <option value="popular">Más populares</option>
                <option value="progreso">Mayor progreso</option>
              </select>
            </div>
          </div>
        </div>

        {/* Proyectos Grid */}
        <div className="grid md:grid-cols-2 gap-8">
          {proyectosOrdenados.map((proyecto) => (
            <div key={proyecto.id} className="bg-white rounded-lg shadow-sm overflow-hidden hover:shadow-lg transition-shadow">
              <div className="p-6">
                <div className="flex justify-between items-start mb-4">
                  <div className="flex items-center space-x-3">
                    <div className="w-10 h-10 bg-gradient-to-br from-blue-400 to-purple-500 rounded-full flex items-center justify-center text-white text-lg">
                      {proyecto.avatar}
                    </div>
                    <div>
                      <p className="font-medium text-gray-800">{proyecto.creador}</p>
                      <p className="text-sm text-gray-600">{proyecto.categoria}</p>
                    </div>
                  </div>
                  <div className="flex space-x-2">
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${getEstadoColor(proyecto.estado)}`}>
                      {proyecto.estado === 'activo' ? 'Activo' :
                       proyecto.estado === 'financiado' ? 'Financiado' :
                       proyecto.estado === 'validacion' ? 'En Validación' : 'Finalizado'}
                    </span>
                    <span className={`px-2 py-1 rounded-full text-xs font-medium ${getRiesgoColor(proyecto.riesgo)}`}>
                      Riesgo {proyecto.riesgo}
                    </span>
                  </div>
                </div>

                <h3 className="text-xl font-semibold text-gray-800 mb-3">{proyecto.titulo}</h3>
                <p className="text-gray-600 mb-4 line-clamp-3">{proyecto.descripcion}</p>

                {/* Progress */}
                <div className="mb-4">
                  <div className="flex justify-between items-center mb-2">
                    <span className="text-sm text-gray-600">Progreso de financiamiento</span>
                    <span className="text-sm font-medium text-gray-800">
                      {Math.round((proyecto.montoRecaudado / proyecto.metaFinanciamiento) * 100)}%
                    </span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-3">
                    <div 
                      className="bg-gradient-to-r from-green-500 to-blue-500 h-3 rounded-full" 
                      style={{ width: `${Math.min((proyecto.montoRecaudado / proyecto.metaFinanciamiento) * 100, 100)}%` }}
                    ></div>
                  </div>
                </div>

                {/* Stats */}
                <div className="grid grid-cols-2 gap-4 mb-4">
                  <div>
                    <p className="text-sm text-gray-600">Recaudado</p>
                    <p className="text-lg font-semibold text-gray-800">{formatCurrency(proyecto.montoRecaudado)}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Meta</p>
                    <p className="text-lg font-semibold text-gray-800">{formatCurrency(proyecto.metaFinanciamiento)}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Inversores</p>
                    <p className="text-lg font-semibold text-gray-800">{proyecto.numeroInversores}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-600">Retorno esperado</p>
                    <p className="text-lg font-semibold text-green-600">{proyecto.porcentajeRetorno}%</p>
                  </div>
                </div>

                {/* Validation badges */}
                <div className="mb-4">
                  <p className="text-sm text-gray-600 mb-2">Validado por:</p>
                  <div className="flex flex-wrap gap-2">
                    {proyecto.validadoPor.map((validador, index) => (
                      <span key={index} className="px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-full">
                        ✓ {validador}
                      </span>
                    ))}
                  </div>
                </div>

                {/* Investment info */}
                <div className="bg-gray-50 rounded-lg p-4 mb-4">
                  <div className="grid grid-cols-2 gap-4 text-sm">
                    <div>
                      <span className="text-gray-600">Inversión mínima:</span>
                      <p className="font-medium text-gray-800">₡{proyecto.minInversion.toLocaleString()}</p>
                    </div>
                    <div>
                      <span className="text-gray-600">Plazo de retorno:</span>
                      <p className="font-medium text-gray-800">{proyecto.plazoRetorno}</p>
                    </div>
                  </div>
                </div>

                {/* Mi inversión actual */}
                {proyecto.miInversion && (
                  <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4">
                    <div className="flex items-center">
                      <svg className="w-5 h-5 text-blue-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                      </svg>
                      <span className="text-blue-800 font-medium">
                        Tu inversión: ₡{proyecto.miInversion.toLocaleString()}
                      </span>
                    </div>
                  </div>
                )}

                {/* Actions */}
                <div className="flex space-x-3">
                  <button 
                    onClick={() => handleInvertir(proyecto.id)}
                    disabled={proyecto.estado !== 'activo'}
                    className={`flex-1 py-3 rounded-lg font-medium transition-colors ${
                      proyecto.estado === 'activo'
                        ? 'bg-green-600 text-white hover:bg-green-700'
                        : 'bg-gray-200 text-gray-500 cursor-not-allowed'
                    }`}
                  >
                    {proyecto.estado === 'activo' ? 'Invertir Ahora' :
                     proyecto.estado === 'financiado' ? 'Financiado' :
                     proyecto.estado === 'validacion' ? 'En Validación' : 'Finalizado'}
                  </button>
                  <button className="px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors">
                    Ver Detalles
                  </button>
                </div>
              </div>
            </div>
          ))}
        </div>

        {proyectosOrdenados.length === 0 && (
          <div className="text-center py-12">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-4m-5 0H9m0 0H5m4 0V9a1 1 0 011-1h4a1 1 0 011 1v4m-5 8H7a2 2 0 01-2-2V9a2 2 0 012-2h2m7 12h2a2 2 0 002-2V9a2 2 0 00-2-2h-2m-7 12V9a1 1 0 011-1h4a1 1 0 011 1v4" />
              </svg>
            </div>
            <h3 className="text-lg font-medium text-gray-800 mb-2">No se encontraron proyectos</h3>
            <p className="text-gray-600">
              Intenta cambiar los filtros o buscar con otros términos.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
