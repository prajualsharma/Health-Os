-- Track NutriKit onboarding progress for abandoned-signup reminders.

CREATE TABLE IF NOT EXISTS consumer.onboarding_sessions (
  id uuid PRIMARY KEY,
  phone varchar(32) NOT NULL,
  registration_token_hash varchar(128) NOT NULL,
  current_step varchar(32) NOT NULL,
  first_name varchar(80),
  email varchar(255),
  last_activity_at timestamptz NOT NULL,
  reminder_sent_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_onboarding_sessions_phone_incomplete
  ON consumer.onboarding_sessions(phone)
  WHERE completed_at IS NULL;

CREATE INDEX IF NOT EXISTS idx_onboarding_sessions_reminder
  ON consumer.onboarding_sessions(last_activity_at)
  WHERE completed_at IS NULL AND reminder_sent_at IS NULL;
