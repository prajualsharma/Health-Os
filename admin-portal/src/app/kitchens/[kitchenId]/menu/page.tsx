'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { api, CatalogItem } from '@/lib/api';
import { isLoggedIn } from '@/lib/auth';

export default function MenuListPage() {
  const { kitchenId } = useParams<{ kitchenId: string }>();
  const router = useRouter();
  const [items, setItems] = useState<CatalogItem[]>([]);
  const [error, setError] = useState('');

  useEffect(() => {
    if (!isLoggedIn()) {
      router.replace('/login');
      return;
    }
    api
      .listCatalogItems(kitchenId, 'CAFE')
      .then(setItems)
      .catch((e) => setError(e.message));
  }, [kitchenId, router]);

  async function remove(id: string) {
    if (!confirm('Delete this item?')) return;
    await api.deleteCatalogItem(id);
    setItems((prev) => prev.filter((i) => i.id !== id));
  }

  return (
    <>
      <nav className="nav">
        <strong>NutriKit Admin</strong>
        <Link href="/dashboard">Kitchens</Link>
        <Link href={`/kitchens/${kitchenId}/sections`}>Sections</Link>
      </nav>
      <main className="container">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <h1>Cafe menu</h1>
          <Link className="btn" href={`/kitchens/${kitchenId}/menu/new`}>
            Add item
          </Link>
        </div>
        {error && <p style={{ color: '#c1121f' }}>{error}</p>}
        <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Price</th>
                <th>Status</th>
                <th />
              </tr>
            </thead>
            <tbody>
              {items.map((item) => (
                <tr key={item.id}>
                  <td>
                    {item.emoji} {item.name}
                  </td>
                  <td>₹{(item.priceCents / 100).toFixed(0)}</td>
                  <td>
                    <span className={`badge ${item.status.toLowerCase()}`}>{item.status}</span>
                  </td>
                  <td>
                    <Link href={`/kitchens/${kitchenId}/menu/${item.id}`}>Edit</Link>{' '}
                    <button className="btn danger" style={{ padding: '4px 8px' }} onClick={() => remove(item.id)}>
                      Delete
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </main>
    </>
  );
}
