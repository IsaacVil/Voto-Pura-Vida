'use client';

import { useState } from 'react';
import Link from 'next/link';

export default function Dashboard() {
  const [usuario] = useState({
    nombre: 'Juan Carlos Rodríguez',
    email: 'juan.rodriguez@email.com',
    cedula: '1-2345-6789',
    verificado: true,
    nivel: 'Ciudadano Verificado'
  });

  // Datos de ejemplo para el dashboard
  const misVotos = [
    {
      id: '1',
      titulo: 'Reforma al Sistema de Pensiones',
      fecha: '2025-06-18',
      miVoto: 'A favor',
      estado: 'activa'
    },
    {
      id: '2',
      titulo: 'Presupuesto Municipal 2026 - Cartago',
      fecha: '2025-05-10',
      miVoto: 'Propuesta B',
      estado: 'finalizada'
    }
  ];

  const misInversiones = [
    {
      id: '1',
      proyecto: 'AgriTech Solutions - IoT para Agricultura',
      montoInvertido: 100000,
      fechaInversion: '2025-05-20',
      estado: 'financiado',
      retornoEsperado: 18,
      progreso: 100
    },
    {
      id: '2',
      proyecto: 'EcoLogistics CR - Delivery Sostenible',
      montoInvertido: 75000,
      fechaInversion: '2025-06-15',
      estado: 'activo',
      retornoEsperado: 15,
      progreso: 46
    }
  ];

  const estadisticas = {
    votacionesParticipadas: 12,
    inversionesTotales: 175000,
    proyectosFinanciados: 1,
    retornoPromedio: 16.5
  };

  const actividadReciente = [
    {
      id: '1',
      tipo: 'voto',
      descripcion: 'Votaste en "Reforma al Sistema de Pensiones"',
      fecha: '2025-06-18',
      icono: '🗳️'
    },
    {
      id: '2',
      tipo: 'inversion',
      descripcion: 'Invertiste ₡75,000 en EcoLogistics CR',
      fecha: '2025-06-15',
      icono: '💰'
    },
    {
      id: '3',
      tipo: 'resultado',
      descripcion: 'Finalizada: "Presupuesto Municipal 2026 - Cartago"',
      fecha: '2025-05-15',
      icono: '📊'
    },
    {
      id: '4',
      tipo: 'inversion',
      descripcion: 'AgriTech Solutions alcanzó su meta de financiamiento',
      fecha: '2025-05-12',
      icono: '🎯'
    }
  ];

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
              <Link href="/votaciones" className="text-gray-700 hover:text-green-600 px-4 py-2 rounded-lg transition-colors">
                Votaciones
              </Link>
              <Link href="/crowdfunding" className="text-gray-700 hover:text-green-600 px-4 py-2 rounded-lg transition-colors">
                Crowdfunding
              </Link>
              <Link href="/perfil" className="text-gray-700 hover:text-green-600 px-4 py-2 rounded-lg transition-colors">
                Mi Perfil
              </Link>
              <button className="text-gray-700 hover:text-red-600 px-4 py-2 rounded-lg transition-colors">
                Cerrar Sesión
              </button>
            </div>
          </div>
        </div>
      </nav>

      <div className="container mx-auto px-6 py-8">
        {/* Header del Dashboard */}
        <div className="mb-8">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-800">
                Bienvenido, {usuario.nombre.split(' ')[0]}
              </h1>
              <p className="text-gray-600 mt-2">
                Tu centro de control para participación ciudadana e inversiones
              </p>
            </div>
            <div className="flex items-center space-x-3 bg-white rounded-lg shadow-sm p-4">
              <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center">
                <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <p className="font-medium text-gray-800">{usuario.nivel}</p>
                <p className="text-sm text-green-600">Verificado ✓</p>
              </div>
            </div>
          </div>
        </div>

        {/* Estadísticas Principales */}
        <div className="grid md:grid-cols-4 gap-6 mb-8">
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mr-4">
                <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <div>
                <p className="text-2xl font-bold text-gray-800">{estadisticas.votacionesParticipadas}</p>
                <p className="text-gray-600 text-sm">Votaciones</p>
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
                <p className="text-2xl font-bold text-gray-800">₡{(estadisticas.inversionesTotales / 1000).toFixed(0)}K</p>
                <p className="text-gray-600 text-sm">Invertido</p>
              </div>
            </div>
          </div>
          
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center">
              <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center mr-4">
                <svg className="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-4m-5 0H9m0 0H5m4 0V9a1 1 0 011-1h4a1 1 0 011 1v4m-5 8H7a2 2 0 01-2-2V9a2 2 0 012-2h2m7 12h2a2 2 0 002-2V9a2 2 0 00-2-2h-2m-7 12V9a1 1 0 011-1h4a1 1 0 011 1v4" />
                </svg>
              </div>
              <div>
                <p className="text-2xl font-bold text-gray-800">{estadisticas.proyectosFinanciados}</p>
                <p className="text-gray-600 text-sm">Financiados</p>
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
                <p className="text-2xl font-bold text-gray-800">{estadisticas.retornoPromedio}%</p>
                <p className="text-gray-600 text-sm">Retorno Prom.</p>
              </div>
            </div>
          </div>
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Actividad Reciente */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-lg shadow-sm p-6">
              <h3 className="text-lg font-semibold text-gray-800 mb-4">Actividad Reciente</h3>
              <div className="space-y-4">
                {actividadReciente.map((actividad) => (
                  <div key={actividad.id} className="flex items-start space-x-3">
                    <div className="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center text-sm">
                      {actividad.icono}
                    </div>
                    <div className="flex-1">
                      <p className="text-sm text-gray-800">{actividad.descripcion}</p>
                      <p className="text-xs text-gray-500">
                        {new Date(actividad.fecha).toLocaleDateString('es-CR')}
                      </p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          {/* Mis Votaciones y Inversiones */}
          <div className="lg:col-span-2 space-y-8">
            {/* Mis Últimas Votaciones */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold text-gray-800">Mis Últimas Votaciones</h3>
                <Link href="/votaciones" className="text-green-600 hover:text-green-700 text-sm font-medium">
                  Ver todas
                </Link>
              </div>
              <div className="space-y-4">
                {misVotos.map((voto) => (
                  <div key={voto.id} className="border border-gray-200 rounded-lg p-4">
                    <div className="flex justify-between items-start">
                      <div className="flex-1">
                        <h4 className="font-medium text-gray-800 mb-1">{voto.titulo}</h4>
                        <div className="flex items-center space-x-4 text-sm text-gray-600">
                          <span>Tu voto: <strong className="text-blue-600">{voto.miVoto}</strong></span>
                          <span>Fecha: {new Date(voto.fecha).toLocaleDateString('es-CR')}</span>
                        </div>
                      </div>
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        voto.estado === 'activa' 
                          ? 'bg-green-100 text-green-800' 
                          : 'bg-gray-100 text-gray-800'
                      }`}>
                        {voto.estado === 'activa' ? 'Activa' : 'Finalizada'}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Mis Inversiones */}
            <div className="bg-white rounded-lg shadow-sm p-6">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-lg font-semibold text-gray-800">Mis Inversiones</h3>
                <Link href="/crowdfunding" className="text-green-600 hover:text-green-700 text-sm font-medium">
                  Ver todas
                </Link>
              </div>
              <div className="space-y-4">
                {misInversiones.map((inversion) => (
                  <div key={inversion.id} className="border border-gray-200 rounded-lg p-4">
                    <div className="flex justify-between items-start mb-3">
                      <div className="flex-1">
                        <h4 className="font-medium text-gray-800 mb-1">{inversion.proyecto}</h4>
                        <div className="flex items-center space-x-4 text-sm text-gray-600">
                          <span>Invertido: <strong>₡{inversion.montoInvertido.toLocaleString()}</strong></span>
                          <span>Retorno: <strong className="text-green-600">{inversion.retornoEsperado}%</strong></span>
                        </div>
                      </div>
                      <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                        inversion.estado === 'activo' 
                          ? 'bg-blue-100 text-blue-800' 
                          : 'bg-green-100 text-green-800'
                      }`}>
                        {inversion.estado === 'activo' ? 'En Progreso' : 'Financiado'}
                      </span>
                    </div>
                    
                    {/* Progress Bar */}
                    <div className="mb-2">
                      <div className="flex justify-between items-center text-sm text-gray-600 mb-1">
                        <span>Progreso del proyecto</span>
                        <span>{inversion.progreso}%</span>
                      </div>
                      <div className="w-full bg-gray-200 rounded-full h-2">
                        <div 
                          className={`h-2 rounded-full ${
                            inversion.progreso === 100 ? 'bg-green-500' : 'bg-blue-500'
                          }`}
                          style={{ width: `${inversion.progreso}%` }}
                        ></div>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>

        {/* Acciones Rápidas */}
        <div className="mt-8">
          <h3 className="text-lg font-semibold text-gray-800 mb-4">Acciones Rápidas</h3>
          <div className="grid md:grid-cols-4 gap-4">
            <Link 
              href="/votaciones" 
              className="bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow text-center"
            >
              <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center mx-auto mb-3">
                <svg className="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <h4 className="font-medium text-gray-800 mb-1">Ver Votaciones</h4>
              <p className="text-sm text-gray-600">Participa en decisiones activas</p>
            </Link>

            <Link 
              href="/crowdfunding" 
              className="bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow text-center"
            >
              <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center mx-auto mb-3">
                <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1" />
                </svg>
              </div>
              <h4 className="font-medium text-gray-800 mb-1">Explorar Proyectos</h4>
              <p className="text-sm text-gray-600">Invierte en innovación</p>
            </Link>

            <Link 
              href="/perfil" 
              className="bg-white rounded-lg shadow-sm p-6 hover:shadow-md transition-shadow text-center"
            >
              <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center mx-auto mb-3">
                <svg className="w-6 h-6 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                </svg>
              </div>
              <h4 className="font-medium text-gray-800 mb-1">Mi Perfil</h4>
              <p className="text-sm text-gray-600">Gestiona tu cuenta</p>
            </Link>

            <div className="bg-white rounded-lg shadow-sm p-6 text-center">
              <div className="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center mx-auto mb-3">
                <svg className="w-6 h-6 text-orange-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.746 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
                </svg>
              </div>
              <h4 className="font-medium text-gray-800 mb-1">Centro de Ayuda</h4>
              <p className="text-sm text-gray-600">Guías y soporte</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
