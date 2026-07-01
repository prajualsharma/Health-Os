'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { api, CatalogItem } from '@/lib/api';
import { isLoggedIn } from '@/lib/auth';

export default function MealPlanPage() {
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
      .listCatalogItems(kitchenId, 'MEAL_PLAN')
      .then(setItems)
      .catch((e) => setError(e.message));
  }, [kitchenId, router]);

  return (
    <>
      <nav className="nav">
        <Link href="/dashboard">Kitchens</Link>
        <strong>Meal plan items</strong>
      </nav>
      <main className="container">
        <h1>NutriPlan catalog</h1>
        <p>Items with channel MEAL_PLAN appear in tomorrow picker APIs.</p>
        {error && <p style={{ color: '#c1121f' }}>{error}</p>}
        <div className="card" style={{ padding: 0 }}>
          <table>
            <thead>
              <tr>
                <th>Name</th>
                <th>Slot</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {items.map((item) => (
                <tr key={item.id}>
                  <td>{item.emoji} {item.name}</td>
                  <td>{item.mealCategory}</td>
                  <td>
                    <span className={`badge ${item.status.toLowerCase()}`}>{item.status}</span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <p style={{ marginTop: 16 }}>
          Create meal-plan items via cafe editor with <code>channelMealPlan</code> enabled (API PATCH).
        </p>
      </main>
    </>
  );
}
