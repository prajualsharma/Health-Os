ALTER TABLE user_profiles
  ADD COLUMN goals TEXT,
  ADD COLUMN medical_conditions TEXT,
  ADD COLUMN city VARCHAR(128),
  ADD COLUMN goal_pace VARCHAR(32),
  ADD COLUMN preferred_height_unit VARCHAR(8) DEFAULT 'cm',
  ADD COLUMN preferred_weight_unit VARCHAR(8) DEFAULT 'kg';
