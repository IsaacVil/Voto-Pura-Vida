'use client';

import { useState } from 'react';
import Link from 'next/link';

interface Votacion {
  id: string;
  titulo: string;
  descripcion: string;
  categoria: string;
  fechaInicio: string;
  fechaFin: string;
  totalVotos: number;
  participacionRequerida: number;
  estado: 'activa' | 'pendiente' | 'finalizada';
  opciones: {
    id: string;
    texto: string;
    votos: number;
    porcentaje: number;
  }[];
  miVoto?: string;
}

export default function Votaciones() {
  const [filtro, setFiltro] = useState('todas');
  const [busqueda, setBusqueda] = useState('');

  // Datos de ejemplo
  const votaciones: Votacion[] = [
    {
      id: '1',
      titulo: 'Implementación de Ciclovías en San José',
      descripcion: 'Propuesta para crear una red de ciclovías que conecte los principales centros de trabajo y estudio en el Gran Área Metropolitana.',
      categoria: 'Infraestructura',
      fechaInicio: '2025-06-15',
      fechaFin: '2025-06-25',
      totalVotos: 1247,
      participacionRequerida: 2000,
      estado: 'activa',
      opciones: [
        { id: 'si', texto: 'A favor', votos: 856, porcentaje: 68.7 },
        { id: 'no', texto: 'En contra', votos: 234, porcentaje: 18.8 },
        { id: 'modificar', texto: 'Con modificaciones', votos: 157, porcentaje: 12.5 }
      ]
    },
    {
      id: '2',
      titulo: 'Reforma al Sistema de Pensiones',
      descripcion: 'Propuesta integral para modernizar el sistema de pensiones costarricense, incluyendo nuevos esquemas de contribución y beneficios.',
      categoria: 'Política Social',
      fechaInicio: '2025-06-20',
      fechaFin: '2025-07-05',
      totalVotos: 3421,
      participacionRequerida: 5000,
      estado: 'activa',
      opciones: [
        { id: 'apruebo', texto: 'Apruebo', votos: 1876, porcentaje: 54.8 },
        { id: 'rechazo', texto: 'Rechazo', votos: 1234, porcentaje: 36.1 },
        { id: 'abstención', texto: 'Abstención', votos: 311, porcentaje: 9.1 }
      ],
      miVoto: 'apruebo'
    },
    {
      id: '3',
      titulo: 'Presupuesto Municipal 2026 - Cartago',
      descripcion: 'Distribución del presupuesto municipal para proyectos de desarrollo local en la provincia de Cartago.',
      categoria: 'Presupuesto',
      fechaInicio: '2025-05-01',
      fechaFin: '2025-05-15',
      totalVotos: 2156,
      participacionRequerida: 1500,
      estado: 'finalizada',
      opciones: [
        { id: 'propuesta_a', texto: 'Propuesta A - Prioridad Educación', votos: 967, porcentaje: 44.9 },
        { id: 'propuesta_b', texto: 'Propuesta B - Prioridad Infraestructura', votos: 1189, porcentaje: 55.1 }
      ]
    }
  ];

  const votacionesFiltradas = votaciones.filter(votacion => {
    const cumpleFiltro = filtro === 'todas' || votacion.estado === filtro;
    const cumpleBusqueda = votacion.titulo.toLowerCase().includes(busqueda.toLowerCase()) ||
                          votacion.categoria.toLowerCase().includes(busqueda.toLowerCase());
    return cumpleFiltro && cumpleBusqueda;
  });

  const handleVotar = (votacionId: string, opcionId: string) => {
    alert(`Voto registrado para la opción: ${opcionId} en la votación: ${votacionId}`);
    // Aquí se haría la llamada al API
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
              <Link href="/crowdfunding" className="text-gray-700 hover:text-green-600 px-4 py-2 rounded-lg transition-colors">
                Crowdfunding
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
          <h1 className="text-3xl font-bold text-gray-800 mb-4">Votaciones</h1>
          <p className="text-gray-600 max-w-2xl">
            Participa en las decisiones importantes para Costa Rica. Tu voto es seguro, 
            anónimo y cuenta para construir el futuro que queremos.
          </p>
        </div>

        {/* Filters and Search */}
        <div className="bg-white rounded-lg shadow-sm p-6 mb-8">
          <div className="grid md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Filtrar por estado
              </label>
              <select
                value={filtro}
                onChange={(e) => setFiltro(e.target.value)}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              >
                <option value="todas">Todas las votaciones</option>
                <option value="activa">Activas</option>
                <option value="pendiente">Pendientes</option>
                <option value="finalizada">Finalizadas</option>
              </select>
            </div>
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                Buscar votación
              </label>
              <input
                type="text"
                value={busqueda}
                onChange={(e) => setBusqueda(e.target.value)}
                placeholder="Buscar por título o categoría..."
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent"
              />
            </div>
          </div>
        </div>

        {/* Stats */}
        <div className="grid md:grid-cols-3 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center mr-4">
                <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <p className="text-2xl font-bold text-gray-800">2</p>
                <p className="text-gray-600 text-sm">Votaciones Activas</p>
              </div>
            </div>
          </div>
          
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mr-4">
                <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z" />
                </svg>
              </div>
              <div>
                <p className="text-2xl font-bold text-gray-800">4,668</p>
                <p className="text-gray-600 text-sm">Total Participantes</p>
              </div>
            </div>
          </div>
          
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center mr-4">
                <svg className="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v4a2 2 0 01-2 2H9a2 2 0 01-2-2z" />
                </svg>
              </div>
              <div>
                <p className="text-2xl font-bold text-gray-800">73%</p>
                <p className="text-gray-600 text-sm">Participación Promedio</p>
              </div>
            </div>
          </div>
        </div>

        {/* Votaciones List */}
        <div className="space-y-6">
          {votacionesFiltradas.map((votacion) => (
            <div key={votacion.id} className="bg-white rounded-lg shadow-sm overflow-hidden">
              <div className="p-6">
                <div className="flex justify-between items-start mb-4">
                  <div className="flex-1">
                    <div className="flex items-center space-x-3 mb-2">
                      <h3 className="text-xl font-semibold text-gray-800">{votacion.titulo}</h3>
                      <span className={`px-3 py-1 rounded-full text-xs font-medium ${
                        votacion.estado === 'activa' 
                          ? 'bg-green-100 text-green-800'
                          : votacion.estado === 'pendiente'
                          ? 'bg-yellow-100 text-yellow-800'
                          : 'bg-gray-100 text-gray-800'
                      }`}>
                        {votacion.estado === 'activa' ? 'Activa' : 
                         votacion.estado === 'pendiente' ? 'Pendiente' : 'Finalizada'}
                      </span>
                      {votacion.miVoto && (
                        <span className="px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                          Ya votaste
                        </span>
                      )}
                    </div>
                    <span className="inline-block px-2 py-1 bg-gray-100 text-gray-700 text-sm rounded mb-3">
                      {votacion.categoria}
                    </span>
                    <p className="text-gray-600 mb-4">{votacion.descripcion}</p>
                    
                    <div className="grid md:grid-cols-2 gap-4 text-sm text-gray-600">
                      <div>
                        <strong>Fecha de inicio:</strong> {new Date(votacion.fechaInicio).toLocaleDateString('es-CR')}
                      </div>
                      <div>
                        <strong>Fecha de cierre:</strong> {new Date(votacion.fechaFin).toLocaleDateString('es-CR')}
                      </div>
                      <div>
                        <strong>Participación:</strong> {votacion.totalVotos.toLocaleString()} / {votacion.participacionRequerida.toLocaleString()} votos
                      </div>
                      <div>
                        <strong>Progreso:</strong> {Math.round((votacion.totalVotos / votacion.participacionRequerida) * 100)}%
                      </div>
                    </div>
                  </div>
                </div>

                {/* Progress Bar */}
                <div className="w-full bg-gray-200 rounded-full h-2 mb-6">
                  <div 
                    className="bg-green-600 h-2 rounded-full" 
                    style={{ width: `${Math.min((votacion.totalVotos / votacion.participacionRequerida) * 100, 100)}%` }}
                  ></div>
                </div>

                {/* Opciones de votación */}
                <div className="space-y-4">
                  <h4 className="font-medium text-gray-800">Opciones de votación:</h4>
                  
                  {votacion.estado === 'activa' && !votacion.miVoto ? (
                    // Votación activa - mostrar botones para votar
                    <div className="grid md:grid-cols-2 gap-3">
                      {votacion.opciones.map((opcion) => (
                        <button
                          key={opcion.id}
                          onClick={() => handleVotar(votacion.id, opcion.id)}
                          className="flex items-center justify-between p-4 border border-gray-300 rounded-lg hover:border-green-500 hover:bg-green-50 transition-colors text-left"
                        >
                          <span className="font-medium text-gray-800">{opcion.texto}</span>
                          <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                          </svg>
                        </button>
                      ))}
                    </div>
                  ) : (
                    // Mostrar resultados
                    <div className="space-y-3">
                      {votacion.opciones.map((opcion) => (
                        <div key={opcion.id} className="relative">
                          <div className="flex justify-between items-center mb-1">
                            <span className={`font-medium ${
                              votacion.miVoto === opcion.id ? 'text-blue-600' : 'text-gray-800'
                            }`}>
                              {opcion.texto}
                              {votacion.miVoto === opcion.id && (
                                <span className="ml-2 text-sm text-blue-600">✓ Tu voto</span>
                              )}
                            </span>
                            <span className="text-sm text-gray-600">
                              {opcion.votos.toLocaleString()} votos ({opcion.porcentaje.toFixed(1)}%)
                            </span>
                          </div>
                          <div className="w-full bg-gray-200 rounded-full h-3">
                            <div 
                              className={`h-3 rounded-full ${
                                votacion.miVoto === opcion.id ? 'bg-blue-500' : 'bg-green-500'
                              }`}
                              style={{ width: `${opcion.porcentaje}%` }}
                            ></div>
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>

        {votacionesFiltradas.length === 0 && (
          <div className="text-center py-12">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
            <h3 className="text-lg font-medium text-gray-800 mb-2">No se encontraron votaciones</h3>
            <p className="text-gray-600">
              Intenta cambiar los filtros o buscar con otros términos.
            </p>
          </div>
        )}
      </div>
    </div>
  );
}
