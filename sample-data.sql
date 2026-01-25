
DELETE FROM materials WHERE topic_id IN (
  SELECT id FROM topics WHERE slug IN ('rownania-liniowe', 'pochodne')
);

DELETE FROM test_questions WHERE test_id IN (
  SELECT id FROM tests WHERE topic_id IN (
    SELECT id FROM topics WHERE slug IN ('rownania-liniowe', 'pochodne')
  )
);

DELETE FROM answers WHERE question_id IN (
  SELECT id FROM questions WHERE id IN (
    SELECT question_id FROM test_questions WHERE test_id IN (
      SELECT id FROM tests WHERE topic_id IN (
        SELECT id FROM topics WHERE slug IN ('rownania-liniowe', 'pochodne')
      )
    )
  )
);

DELETE FROM questions WHERE id IN (
  SELECT question_id FROM test_questions WHERE test_id IN (
    SELECT id FROM tests WHERE topic_id IN (
      SELECT id FROM topics WHERE slug IN ('rownania-liniowe', 'pochodne')
    )
  )
);

DELETE FROM tests WHERE topic_id IN (
  SELECT id FROM topics WHERE slug IN ('rownania-liniowe', 'pochodne')
);

DELETE FROM topics WHERE slug IN ('rownania-liniowe', 'pochodne');

DELETE FROM categories WHERE slug IN ('algebra', 'geometria', 'analiza', 'trygonometria');

DELETE FROM education_levels WHERE slug IN ('szkola-podstawowa', 'liceum', 'studia');

-- ============================================
-- KROK 2: DODANIE NOWYCH DANYCH
-- ============================================

-- 1. POZIOMY EDUKACJI
INSERT INTO education_levels (name, slug, description, display_order, is_published) VALUES
('Szkoła Podstawowa', 'szkola-podstawowa', 'Matematyka dla klas 4-8', 1, true),
('Liceum', 'liceum', 'Matematyka poziom podstawowy i rozszerzony', 2, true),
('Studia', 'studia', 'Matematyka wyższa', 3, true);

-- 2. KATEGORIE
DO $$
DECLARE
  podstawowa_id UUID;
  liceum_id UUID;
BEGIN
  SELECT id INTO podstawowa_id FROM education_levels WHERE slug = 'szkola-podstawowa';
  SELECT id INTO liceum_id FROM education_levels WHERE slug = 'liceum';

  -- Kategorie dla szkoły podstawowej
  INSERT INTO categories (education_level_id, name, slug, description, icon, display_order, is_published) VALUES
  (podstawowa_id, 'Algebra', 'algebra', 'Równania, nierówności, funkcje', 'i-heroicons-variable', 1, true),
  (podstawowa_id, 'Geometria', 'geometria', 'Figury płaskie i bryły', 'i-heroicons-cube', 2, true);

  -- Kategorie dla liceum
  INSERT INTO categories (education_level_id, name, slug, description, icon, display_order, is_published) VALUES
  (liceum_id, 'Analiza Matematyczna', 'analiza', 'Pochodne, całki, granice', 'i-heroicons-chart-bar', 1, true),
  (liceum_id, 'Trygonometria', 'trygonometria', 'Funkcje trygonometryczne', 'i-heroicons-chart-pie', 2, true);
END $$;

-- 3. TEMATY
DO $$
DECLARE
  algebra_id UUID;
  analiza_id UUID;
BEGIN
  SELECT id INTO algebra_id FROM categories WHERE slug = 'algebra' AND education_level_id = (SELECT id FROM education_levels WHERE slug = 'szkola-podstawowa') LIMIT 1;
  SELECT id INTO analiza_id FROM categories WHERE slug = 'analiza' LIMIT 1;

  -- Temat 1: Równania liniowe (pokazuje wszystkie typy bloków)
  INSERT INTO topics (
    category_id, 
    name, 
    slug, 
    description, 
    learning_objectives,
    estimated_time,
    difficulty_level,
    display_order,
    is_published,
    seo_title,
    seo_description
  ) VALUES (
    algebra_id,
    'Równania Liniowe',
    'rownania-liniowe',
    'Poznaj podstawy rozwiązywania równań liniowych krok po kroku',
    '["Rozumienie pojęcia równania", "Rozwiązywanie równań jednej niewiadomej", "Sprawdzanie poprawności rozwiązań"]'::jsonb,
    45,
    'basic',
    1,
    true,
    'Równania Liniowe - Jak Rozwiązywać Krok po Kroku',
    'Naucz się rozwiązywać równania liniowe. Teoria, przykłady i ćwiczenia.'
  );

  -- Temat 2: Pochodne
  INSERT INTO topics (
    category_id,
    name,
    slug,
    description,
    learning_objectives,
    estimated_time,
    difficulty_level,
    display_order,
    is_published
  ) VALUES (
    analiza_id,
    'Pochodne Funkcji',
    'pochodne',
    'Wprowadzenie do rachunku różniczkowego i pochodnych funkcji',
    '["Definicja pochodnej", "Wzory na pochodne", "Interpretacja geometryczna"]'::jsonb,
    60,
    'intermediate',
    1,
    true
  );
END $$;

-- 4. MATERIAŁY Z BLOKAMI TREŚCI
DO $$
DECLARE
  topic_id UUID;
BEGIN
  SELECT id INTO topic_id FROM topics WHERE slug = 'rownania-liniowe' LIMIT 1;

  -- MATERIAŁ 1: TEORIA - Pokazuje wszystkie typy bloków
  INSERT INTO materials (topic_id, type, title, display_order, content, is_published) VALUES (
    topic_id,
    'theory',
    'Wprowadzenie do Równań Liniowych',
    1,
    '[
      {
        "id": "block-1",
        "type": "heading",
        "order": 1,
        "content": {
          "level": 2,
          "text": "Czym jest równanie liniowe?"
        }
      },
      {
        "id": "block-2",
        "type": "text",
        "order": 2,
        "content": {
          "markdown": "Równanie liniowe to równanie, w którym niewiadoma występuje w **pierwszej potędze**. Ogólna postać równania liniowego jednej niewiadomej to:\n\nGdzie *a* i *b* są liczbami rzeczywistymi, a *x* jest niewiadomą."
        }
      },
      {
        "id": "block-3",
        "type": "formula",
        "order": 3,
        "content": {
          "latex": "ax + b = 0, gdzie a ≠ 0"
        }
      },
      {
        "id": "block-4",
        "type": "callout",
        "order": 4,
        "content": {
          "title": "Ważne!",
          "text": "Współczynnik **a** nie może być zerem, ponieważ wtedy równanie przestaje być równaniem liniowym.",
          "color": "yellow",
          "variant": "subtle",
          "icon": "i-heroicons-exclamation-triangle"
        }
      },
      {
        "id": "block-5",
        "type": "heading",
        "order": 5,
        "content": {
          "level": 3,
          "text": "Jak rozwiązać równanie liniowe?"
        }
      },
      {
        "id": "block-6",
        "type": "text",
        "order": 6,
        "content": {
          "markdown": "Aby rozwiązać równanie liniowe, wykonujemy następujące kroki:\n\n1. Przenosimy wszystkie wyrazy z niewiadomą na lewą stronę\n2. Przenosimy wyrazy bez niewiadomej na prawą stronę\n3. Dzielimy obie strony przez współczynnik przy niewiadomej"
        }
      },
      {
        "id": "block-7",
        "type": "divider",
        "order": 7,
        "content": {}
      }
    ]'::jsonb,
    true
  );

  -- MATERIAŁ 2: PRZYKŁAD - Z tabelą i kodem
  INSERT INTO materials (topic_id, type, title, display_order, content, is_published) VALUES (
    topic_id,
    'example',
    'Przykład Rozwiązania',
    2,
    '[
      {
        "id": "ex-1",
        "type": "heading",
        "order": 1,
        "content": {
          "level": 3,
          "text": "Przykład 1: Rozwiąż równanie"
        }
      },
      {
        "id": "ex-2",
        "type": "formula",
        "order": 2,
        "content": {
          "latex": "2x + 5 = 13"
        }
      },
      {
        "id": "ex-3",
        "type": "heading",
        "order": 3,
        "content": {
          "level": 4,
          "text": "Rozwiązanie krok po kroku:"
        }
      },
      {
        "id": "ex-4",
        "type": "table",
        "order": 4,
        "content": {
          "headers": ["Krok", "Działanie", "Wynik"],
          "rows": [
            ["1", "Odejmujemy 5 od obu stron", "2x = 8"],
            ["2", "Dzielimy obie strony przez 2", "x = 4"],
            ["3", "Sprawdzenie: 2·4 + 5", "13 ✓"]
          ]
        }
      },
      {
        "id": "ex-5",
        "type": "callout",
        "order": 5,
        "content": {
          "title": "Odpowiedź",
          "text": "Rozwiązaniem równania jest **x = 4**",
          "color": "green",
          "variant": "subtle",
          "icon": "i-heroicons-check-circle"
        }
      }
    ]'::jsonb,
    true
  );

  -- MATERIAŁ 3: ĆWICZENIE - Z kodem i obrazem
  INSERT INTO materials (topic_id, type, title, display_order, content, is_published) VALUES (
    topic_id,
    'exercise',
    'Zadania do Samodzielnego Rozwiązania',
    3,
    '[
      {
        "id": "task-1",
        "type": "text",
        "order": 1,
        "content": {
          "markdown": "Rozwiąż następujące równania:\n\n1. 3x - 7 = 11\n2. 5x + 2 = 22\n3. -2x + 8 = 2"
        }
      },
      {
        "id": "task-2",
        "type": "callout",
        "order": 2,
        "content": {
          "title": "Wskazówka",
          "text": "Pamiętaj o znakach! Gdy przenosisz wyraz na drugą stronę równania, zmieniasz jego znak na przeciwny.",
          "color": "blue",
          "variant": "subtle",
          "icon": "i-heroicons-light-bulb"
        }
      },
      {
        "id": "task-3",
        "type": "heading",
        "order": 3,
        "content": {
          "level": 4,
          "text": "Dla programistów: Algorytm w JavaScript"
        }
      },
      {
        "id": "task-4",
        "type": "code",
        "order": 4,
        "content": {
          "code": "function solveLinearEquation(a, b) {\n  // Rozwiązuje równanie: ax + b = 0\n  if (a === 0) {\n    return null; // Brak rozwiązania lub nieskończenie wiele\n  }\n  return -b / a;\n}\n\n// Przykład użycia:\nconsole.log(solveLinearEquation(2, -8)); // 4"
        }
      }
    ]'::jsonb,
    true
  );

  -- MATERIAŁ 4: PODSUMOWANIE
  INSERT INTO materials (topic_id, type, title, display_order, content, is_published) VALUES (
    topic_id,
    'summary',
    'Podsumowanie',
    4,
    '[
      {
        "id": "sum-1",
        "type": "heading",
        "order": 1,
        "content": {
          "level": 2,
          "text": "Kluczowe Informacje"
        }
      },
      {
        "id": "sum-2",
        "type": "text",
        "order": 2,
        "content": {
          "markdown": "W tej lekcji nauczyłeś się:\n\n- Czym jest równanie liniowe\n- Jak je rozwiązywać krok po kroku\n- Jak sprawdzać poprawność rozwiązania"
        }
      },
      {
        "id": "sum-3",
        "type": "callout",
        "order": 3,
        "content": {
          "title": "Następny krok",
          "text": "Teraz możesz przejść do **testów sprawdzających** aby sprawdzić swoją wiedzę!",
          "color": "primary",
          "variant": "subtle",
          "icon": "i-heroicons-arrow-right"
        }
      }
    ]'::jsonb,
    true
  );
END $$;

-- 5. PRZYKŁADOWY TEST
DO $$
DECLARE
  topic_id UUID;
  test_id UUID;
  q1_id UUID;
  q2_id UUID;
  q3_id UUID;
BEGIN
  SELECT id INTO topic_id FROM topics WHERE slug = 'rownania-liniowe' LIMIT 1;

  -- Tworzymy test
  INSERT INTO tests (topic_id, title, description, time_limit, passing_score, is_published, show_correct_answers, randomize_questions)
  VALUES (
    topic_id,
    'Test: Równania Liniowe - Podstawy',
    'Sprawdź swoją wiedzę na temat rozwiązywania równań liniowych',
    15,
    70,
    true,
    true,
    false
  )
  RETURNING id INTO test_id;

  -- Pytanie 1
  INSERT INTO questions (content, explanation, difficulty_level)
  VALUES (
    'Rozwiąż równanie: 2x + 6 = 14',
    'Odejmujemy 6 od obu stron: 2x = 8, następnie dzielimy przez 2: x = 4',
    'basic'
  )
  RETURNING id INTO q1_id;

  -- Odpowiedzi do pytania 1
  INSERT INTO answers (question_id, content, label, is_correct, display_order) VALUES
  (q1_id, 'x = 4', 'A', true, 1),
  (q1_id, 'x = 8', 'B', false, 2),
  (q1_id, 'x = 2', 'C', false, 3),
  (q1_id, 'x = 10', 'D', false, 4);

  -- Pytanie 2
  INSERT INTO questions (content, explanation, difficulty_level)
  VALUES (
    'Co to jest równanie liniowe?',
    'Równanie liniowe to równanie, w którym niewiadoma występuje w pierwszej potędze.',
    'basic'
  )
  RETURNING id INTO q2_id;

  -- Odpowiedzi do pytania 2
  INSERT INTO answers (question_id, content, label, is_correct, display_order) VALUES
  (q2_id, 'Równanie, w którym niewiadoma występuje w pierwszej potędze', 'A', true, 1),
  (q2_id, 'Równanie, w którym niewiadoma występuje w drugiej potędze', 'B', false, 2),
  (q2_id, 'Równanie z dwiema niewiadomymi', 'C', false, 3),
  (q2_id, 'Równanie bez rozwiązania', 'D', false, 4);

  -- Pytanie 3
  INSERT INTO questions (content, explanation, difficulty_level)
  VALUES (
    'Rozwiąż równanie: 5x - 15 = 0',
    '5x = 15, więc x = 3',
    'basic'
  )
  RETURNING id INTO q3_id;

  -- Odpowiedzi do pytania 3
  INSERT INTO answers (question_id, content, label, is_correct, display_order) VALUES
  (q3_id, 'x = 3', 'A', true, 1),
  (q3_id, 'x = 5', 'B', false, 2),
  (q3_id, 'x = -3', 'C', false, 3),
  (q3_id, 'x = 0', 'D', false, 4);

  -- Dodajemy pytania do testu
  INSERT INTO test_questions (test_id, question_id, display_order, points) VALUES
  (test_id, q1_id, 1, 1),
  (test_id, q2_id, 2, 1),
  (test_id, q3_id, 3, 1);
END $$;

-- ============================================
-- GOTOWE! PODSUMOWANIE
-- ============================================

SELECT 
  '✅ Dane zostały dodane pomyślnie!' as status,
  (SELECT COUNT(*) FROM education_levels WHERE slug IN ('szkola-podstawowa', 'liceum', 'studia')) as "Poziomy edukacji",
  (SELECT COUNT(*) FROM categories WHERE slug IN ('algebra', 'geometria', 'analiza', 'trygonometria')) as "Kategorie",
  (SELECT COUNT(*) FROM topics WHERE slug IN ('rownania-liniowe', 'pochodne')) as "Tematy",
  (SELECT COUNT(*) FROM materials WHERE topic_id IN (SELECT id FROM topics WHERE slug = 'rownania-liniowe')) as "Materiały",
  (SELECT COUNT(*) FROM tests WHERE topic_id IN (SELECT id FROM topics WHERE slug = 'rownania-liniowe')) as "Testy",
  (SELECT COUNT(*) FROM questions WHERE id IN (SELECT question_id FROM test_questions WHERE test_id IN (SELECT id FROM tests WHERE topic_id IN (SELECT id FROM topics WHERE slug = 'rownania-liniowe')))) as "Pytania";
