// orders-cli reads "customer,total" lines from stdin or a file and prints totals per customer.
package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"os"
	"sort"
	"strconv"
	"strings"
)

// Totals sums amounts per customer from "customer,total" lines.
func Totals(r io.Reader) (map[string]float64, error) {
	out := map[string]float64{}
	sc := bufio.NewScanner(r)
	for n := 1; sc.Scan(); n++ {
		line := strings.TrimSpace(sc.Text())
		if line == "" {
			continue
		}
		parts := strings.Split(line, ",")
		if len(parts) != 2 {
			return nil, fmt.Errorf("line %d: want customer,total", n)
		}
		v, err := strconv.ParseFloat(parts[1], 64)
		if err != nil {
			return nil, fmt.Errorf("line %d: %w", n, err)
		}
		out[parts[0]] += v
	}
	return out, sc.Err()
}

func run(args []string, stdin io.Reader, stdout, stderr io.Writer) int {
	fs := flag.NewFlagSet("orders-cli", flag.ContinueOnError)
	fs.SetOutput(stderr)
	file := fs.String("f", "", "input file (default: stdin)")
	if err := fs.Parse(args); err != nil {
		return 2
	}
	in := stdin
	if *file != "" {
		f, err := os.Open(*file)
		if err != nil {
			fmt.Fprintln(stderr, "error:", err)
			return 1
		}
		defer f.Close()
		in = f
	}
	totals, err := Totals(in)
	if err != nil {
		fmt.Fprintln(stderr, "error:", err)
		return 1
	}
	names := make([]string, 0, len(totals))
	for k := range totals {
		names = append(names, k)
	}
	sort.Strings(names)
	for _, k := range names {
		fmt.Fprintf(stdout, "%s %.2f\n", k, totals[k])
	}
	return 0
}

func main() {
	os.Exit(run(os.Args[1:], os.Stdin, os.Stdout, os.Stderr))
}
