package domain

import "testing"

func TestOrderStatusTransitions(t *testing.T) {
	if !OrderStatusNew.CanTransitionTo(OrderStatusAccepted) {
		t.Fatal("NEW -> ACCEPTED should be allowed")
	}
	if OrderStatusPickedUp.CanTransitionTo(OrderStatusNew) {
		t.Fatal("PICKED_UP -> NEW should be denied")
	}
}
