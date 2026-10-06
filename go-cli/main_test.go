package main

import (
	"bytes"
	"strings"
	"testing"
)

func TestRunSumsPerCustomer(t *testing.T) {
	var out, errb bytes.Buffer
	code := run(nil, strings.NewReader("ana,10.5\nbo,4.25\nana,5\n"), &out, &errb)
	if code != 0 || out.String() != "ana 15.50\nbo 4.25\n" {
		t.Fatalf("code=%d out=%q err=%q", code, out.String(), errb.String())
	}
}

func TestRunRejectsBadLine(t *testing.T) {
	var out, errb bytes.Buffer
	if code := run(nil, strings.NewReader("ana,x\n"), &out, &errb); code != 1 {
		t.Fatalf("want exit 1, got %d", code)
	}
}

func TestRunMissingFile(t *testing.T) {
	var out, errb bytes.Buffer
	if code := run([]string{"-f", "/nonexistent"}, nil, &out, &errb); code != 1 {
		t.Fatalf("want exit 1, got %d", code)
	}
}
