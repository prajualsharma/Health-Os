package domain

import "testing"

func TestResultSentStatus(t *testing.T) {
	r := ResultSent("SMTP", "hello", "{}", "{}")
	if r.Status != StatusSent {
		t.Fatalf("expected SENT, got %s", r.Status)
	}
}
