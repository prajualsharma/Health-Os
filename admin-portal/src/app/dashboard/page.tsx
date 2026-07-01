'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { api, Kitchen } from '@/lib/api';
import { clearToken, isLoggedIn } from '@/lib/auth';

export default function DashboardPage() {
  const router = useRouter();
  const [kitchens, setKitchens] = useState<Kitchen[]>([]);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!isLoggedIn()) {
      router.replace('/login');
      return;
    }
    api
      .listKitchens()
      .then(setKitchens)
      .catch((e) => setError(e.message));
  }, [router]);

  function logout() {
    clearToken();
    router.push('/login');
  }

  return (
    <>
      <nav className="nav">
        <strong>NutriKit Admin</strong>
        <Link href="/dashboard">Kitchens</Link>
        <button className="btn secondary" onClick={logout}>
          Logout
        </button>
      </nav>
      <main className="container">
        <h1>Select kitchen</h1>
        {error && <p style={{ color: '#c1121f' }}>{error}</p>}
        <div style={{ display: 'grid', gap: 12 }}>
          {kitchens.map((k) => (
            <div key={k.id} className="card">
              <h3 style={{ margin: '0 0 8px' }}>{k.name}</h3>
              <p style={{ margin: '0 0 12px', color: '#5c6b5c' }}>{k.city}</p>
              <Link className="btn" href={`/kitchens/${k.id}/menu`}>
                Manage cafe menu
              </Link>{' '}
              <Link className="btn secondary" href={`/kitchens/${k.id}/sections`}>
                Section manager
              </Link>{' '}
              <Link className="btn secondary" href={`/kitchens/${k.id}/meal-plan`}>
                Meal plan
              </Link>
            </div>
          ))}
        </div>
      </main>
    </>
  );
}
