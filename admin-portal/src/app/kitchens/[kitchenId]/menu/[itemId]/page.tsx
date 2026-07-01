'use client';

import { FormEvent, useEffect, useState } from 'react';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { api } from '@/lib/api';
import { isLoggedIn } from '@/lib/auth';

const categories = ['BEVERAGE', 'SNACK', 'BREAKFAST', 'LUNCH', 'DINNER', 'MEALS', 'PARTY'];

export default function ItemEditorPage() {
  const { kitchenId, itemId } = useParams<{ kitchenId: string; itemId: string }>();
  const isNew = itemId === 'new';
  const router = useRouter();
  const [form, setForm] = useState({
    name: '',
    description: '',
    mealCategory: 'BEVERAGE',
    priceCents: 9900,
    veg: true,
    status: 'DRAFT' as 'DRAFT' | 'PUBLISHED',
    channelCafe: true,
    channelMealPlan: false,
    channelRecipe: false,
    emoji: '🍽️',
    imageUrl: '',
    portion: '350g',
    prepTimeMins: 15,
    calories: 0,
    protein: 0,
    kitchenName: 'NutriCafe',
    isAddOn: true,
    isMostLoved: false,
    isHighlyReordered: false,
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [recipeSteps, setRecipeSteps] = useState('Mix batter\nCook until golden');
  const [recipeIngredients, setRecipeIngredients] = useState('Moong dal batter,120\nOnion,30');

  useEffect(() => {
    if (!isLoggedIn()) {
      router.replace('/login');
      return;
    }
    if (!isNew) {
      api
        .getCatalogItem(itemId)
        .then((item) =>
          setForm({
            name: item.name,
            description: item.description,
            mealCategory: item.mealCategory,
            priceCents: item.priceCents,
            veg: item.veg,
            status: item.status,
            channelCafe: item.channelCafe,
            channelMealPlan: item.channelMealPlan,
            channelRecipe: item.channelRecipe,
            emoji: item.emoji,
            imageUrl: item.imageUrl,
            portion: item.portion,
            prepTimeMins: item.prepTimeMins,
            calories: item.calories,
            protein: item.protein,
            kitchenName: item.kitchenName,
            isAddOn: item.isAddOn,
            isMostLoved: item.isMostLoved,
            isHighlyReordered: item.isHighlyReordered,
          }),
        )
        .catch((e) => setError(e.message));
    }
  }, [itemId, isNew, router]);

  async function onSubmit(e: FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError('');
    try {
      if (isNew) {
        const created = await api.createCatalogItem(kitchenId, form);
        if (form.channelRecipe) {
          await api.upsertRecipe(created.id, recipePayload());
        }
      } else {
        await api.updateCatalogItem(itemId, form);
        if (form.channelRecipe) {
          await api.upsertRecipe(itemId, recipePayload());
        }
      }
      router.push(`/kitchens/${kitchenId}/menu`);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Save failed');
    } finally {
      setLoading(false);
    }
  }

  function set<K extends keyof typeof form>(key: K, value: (typeof form)[K]) {
    setForm((prev) => ({ ...prev, [key]: value }));
  }

  function recipePayload() {
    const ingredients = recipeIngredients
      .split('\n')
      .map((line) => line.trim())
      .filter(Boolean)
      .map((line) => {
        const [name, grams] = line.split(',');
        return { name: name.trim(), grams: Number(grams?.trim() ?? 0) };
      });
    const steps = recipeSteps.split('\n').map((s) => s.trim()).filter(Boolean);
    return {
      slot: form.mealCategory === 'BREAKFAST' ? 'Breakfast' : 'Lunch',
      cookTimeMins: form.prepTimeMins,
      difficulty: 'Easy',
      fitsGoal: true,
      ingredients,
      steps,
    };
  }

  return (
    <>
      <nav className="nav">
        <Link href={`/kitchens/${kitchenId}/menu`}>← Back to menu</Link>
      </nav>
      <main className="container" style={{ maxWidth: 560 }}>
        <h1>{isNew ? 'New cafe item' : 'Edit item'}</h1>
        <form onSubmit={onSubmit} className="card">
          <label className="field">
            Name
            <input value={form.name} onChange={(e) => set('name', e.target.value)} required />
          </label>
          <label className="field">
            Description
            <textarea value={form.description} onChange={(e) => set('description', e.target.value)} rows={3} />
          </label>
          <label className="field">
            Category
            <select value={form.mealCategory} onChange={(e) => set('mealCategory', e.target.value)}>
              {categories.map((c) => (
                <option key={c} value={c}>
                  {c}
                </option>
              ))}
            </select>
          </label>
          <label className="field">
            Price (paise)
            <input
              type="number"
              value={form.priceCents}
              onChange={(e) => set('priceCents', Number(e.target.value))}
              required
            />
          </label>
          <label className="field">
            Image URL
            <input value={form.imageUrl} onChange={(e) => set('imageUrl', e.target.value)} />
          </label>
          <label className="field">
            Emoji
            <input value={form.emoji} onChange={(e) => set('emoji', e.target.value)} />
          </label>
          <label className="field">
            Status
            <select value={form.status} onChange={(e) => set('status', e.target.value as 'DRAFT' | 'PUBLISHED')}>
              <option value="DRAFT">DRAFT</option>
              <option value="PUBLISHED">PUBLISHED</option>
            </select>
          </label>
          <label>
            <input type="checkbox" checked={form.veg} onChange={(e) => set('veg', e.target.checked)} /> Veg
          </label>{' '}
          <label>
            <input type="checkbox" checked={form.isMostLoved} onChange={(e) => set('isMostLoved', e.target.checked)} /> Most loved
          </label>
          <div style={{ marginTop: 12 }}>
            <strong>Channels</strong>
            <div>
              <label>
                <input type="checkbox" checked={form.channelCafe} onChange={(e) => set('channelCafe', e.target.checked)} /> Cafe
              </label>{' '}
              <label>
                <input type="checkbox" checked={form.channelMealPlan} onChange={(e) => set('channelMealPlan', e.target.checked)} /> Meal plan
              </label>{' '}
              <label>
                <input type="checkbox" checked={form.channelRecipe} onChange={(e) => set('channelRecipe', e.target.checked)} /> Recipe
              </label>
            </div>
          </div>
          {form.channelRecipe && (
            <div style={{ marginTop: 16 }}>
              <strong>Recipe editor</strong>
              <label className="field">
                Ingredients (name,grams per line)
                <textarea value={recipeIngredients} onChange={(e) => setRecipeIngredients(e.target.value)} rows={4} />
              </label>
              <label className="field">
                Steps (one per line)
                <textarea value={recipeSteps} onChange={(e) => setRecipeSteps(e.target.value)} rows={4} />
              </label>
            </div>
          )}
          <div style={{ marginTop: 16 }}>
            <button className="btn" type="submit" disabled={loading}>
              {loading ? 'Saving…' : 'Save'}
            </button>
          </div>
        </form>
        {error && <p style={{ color: '#c1121f' }}>{error}</p>}
      </main>
    </>
  );
}
