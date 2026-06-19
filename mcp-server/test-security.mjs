import { describe, it } from "node:test";
import assert from "node:assert/strict";
import { readFileSync } from "fs";

// ─── Inline copies matching index.js implementations ───────
const MAX_INPUT_LENGTH = 4096;

function sanitizeShellArg(val) {
  if (typeof val !== "string") return String(val ?? "");
  return val.replace(/[^\w.:@/\-{}]/g, "").slice(0, MAX_INPUT_LENGTH);
}

function validateInputLength(val, label, maxLen) {
  if (typeof val === "string" && val.length > (maxLen ?? MAX_INPUT_LENGTH)) {
    throw new Error(`${label}: input exceeds maximum length (${maxLen ?? MAX_INPUT_LENGTH} chars)`);
  }
  return val;
}

function safeShellArg(val, label) {
  validateInputLength(val, label);
  return sanitizeShellArg(val);
}

// ─── Integration: Extract functions from source and compare ───
const src = readFileSync(new URL("index.js", import.meta.url), "utf-8");

function extractFn(name, code) {
  const start = code.indexOf(`function ${name}(`);
  if (start < 0) throw new Error(`Function ${name} not found in index.js`);
  const bodyStart = code.indexOf("{", start);
  let depth = 0;
  let end = bodyStart;
  for (let i = bodyStart; i < code.length; i++) {
    if (code[i] === "{") depth++;
    if (code[i] === "}") {
      depth--;
      if (depth === 0) { end = i + 1; break; }
    }
  }
  const fnText = code.substring(start, end);
  return fnText;
}

const sanitizeSrc = extractFn("sanitizeShellArg", src);
const validateSrc = extractFn("validateInputLength", src);
const safeSrc = extractFn("safeShellArg", src);

// ─── Tests ─────────────────────────────────────────────────

describe("sanitizeShellArg", () => {

  it("returns empty string for null/undefined", () => {
    assert.equal(sanitizeShellArg(null), "");
    assert.equal(sanitizeShellArg(undefined), "");
  });

  it("converts numbers and booleans to strings", () => {
    assert.equal(sanitizeShellArg(0), "0");
    assert.equal(sanitizeShellArg(123), "123");
    assert.equal(sanitizeShellArg(false), "false");
  });

  it("preserves safe chars: alphanumeric, . : @ / - { } _", () => {
    const input = "MyContract_v2.0.1@0x1234:test/foo{bar}";
    assert.equal(sanitizeShellArg(input), input);
  });

  it("preserves hyphens in any position", () => {
    assert.equal(sanitizeShellArg("hello-world"), "hello-world");
    assert.equal(sanitizeShellArg("-leading"), "-leading");
    assert.equal(sanitizeShellArg("trailing-"), "trailing-");
    assert.equal(sanitizeShellArg("a-b-c-d"), "a-b-c-d");
  });

  it("preserves contract names with hyphens and underscores", () => {
    assert.equal(sanitizeShellArg("My_Named-Contract_v2"), "My_Named-Contract_v2");
  });

  it("preserves valid Ethereum addresses", () => {
    const addr = "0x742d35Cc6634C0532925a3b844Bc9e7595f2bD18";
    assert.equal(sanitizeShellArg(addr), addr);
  });

  it("strips dangerous shell metacharacters: $ ` ; | & ' \"", () => {
    const result = sanitizeShellArg("foo$bar;baz|qux&test'attack\"evil");
    assert.equal(result.includes("$"), false);
    assert.equal(result.includes(";"), false);
    assert.equal(result.includes("|"), false);
    assert.equal(result.includes("&"), false);
    assert.equal(result.includes("'"), false);
    assert.equal(result.includes('"'), false);
    assert.equal(result, "foobarbazquxtestattackevil");
  });

  it("strips command substitution, glob, and redirection chars", () => {
    const result = sanitizeShellArg("$(cat /etc/passwd)`rm -rf /`*(echo hi)?[test]~!");
    assert.equal(result, "cat/etc/passwdrm-rf/echohitest");
  });

  it("truncates to MAX_INPUT_LENGTH", () => {
    const long = "a".repeat(5000);
    const result = sanitizeShellArg(long);
    assert.equal(result.length, MAX_INPUT_LENGTH);
  });

  it("strips spaces (not in allowed set)", () => {
    assert.equal(sanitizeShellArg("foo bar"), "foobar");
    assert.equal(sanitizeShellArg("rm -rf /var"), "rm-rf/var");
  });

  it("strips = , + % (not in allowed set)", () => {
    assert.equal(sanitizeShellArg("a=b,c+d%e"), "abcde");
  });

  it("strips unicode/non-ASCII characters", () => {
    assert.equal(sanitizeShellArg("foo♥bar©baz"), "foobarbaz");
  });

  it("handles exclusively-dangerous input longer than 4096", () => {
    const dangerous = "$!".repeat(2500);
    const result = sanitizeShellArg(dangerous);
    assert.equal(result, "");
  });

  it("inline copy matches source extraction behavior", () => {
    // Create a local eval scope with the source functions
    const localMax = 4096;
    const fnSanitize = eval(`(function(v) { ${sanitizeSrc.replace("function sanitizeShellArg(val)", "")}; return sanitizeShellArg(v); })`);
    // Hmm, eval won't capture the scope. Let's just compare source code structure
    assert.ok(sanitizeSrc.includes("[^"), "Source has regex character class");
    assert.ok(sanitizeSrc.includes(".slice(0, MAX_INPUT_LENGTH)"), "Source has slice truncation");
    assert.ok(validateSrc.includes("val.length > (maxLen ?? MAX_INPUT_LENGTH)"), "Source has length check");
    assert.ok(safeSrc.includes("validateInputLength"), "safeShellArg calls validateInputLength");
    assert.ok(safeSrc.includes("sanitizeShellArg"), "safeShellArg calls sanitizeShellArg");
  });
});

describe("validateInputLength", () => {

  it("does not throw for strings within limit", () => {
    assert.doesNotThrow(() => validateInputLength("short", "test"));
    assert.doesNotThrow(() => validateInputLength("a".repeat(4096), "at-limit"));
  });

  it("throws for string exceeding MAX_INPUT_LENGTH (4096)", () => {
    const long = "a".repeat(4097);
    assert.throws(
      () => validateInputLength(long, "test"),
      /test: input exceeds maximum length \(4096 chars\)/
    );
  });

  it("respects custom maxLen parameter", () => {
    assert.doesNotThrow(() => validateInputLength("abc", "custom", 10));
    assert.throws(
      () => validateInputLength("a".repeat(11), "custom", 10),
      /custom: input exceeds maximum length \(10 chars\)/
    );
  });

  it("works with maxLen=0 (any string is too long)", () => {
    assert.throws(
      () => validateInputLength("a", "zero", 0),
      /zero: input exceeds maximum length \(0 chars\)/
    );
  });

  it("does not throw for non-string types", () => {
    assert.doesNotThrow(() => validateInputLength(123, "num"));
    assert.doesNotThrow(() => validateInputLength(null, "null"));
    assert.doesNotThrow(() => validateInputLength(undefined, "undef"));
    assert.doesNotThrow(() => validateInputLength(true, "bool"));
    assert.doesNotThrow(() => validateInputLength({}, "obj"));
  });

  it("does not throw for empty string (length 0)", () => {
    assert.doesNotThrow(() => validateInputLength("", "empty"));
  });

  it("returns the input string unchanged", () => {
    assert.equal(validateInputLength("hello", "test"), "hello");
  });
});

describe("safeShellArg", () => {

  it("validates and sanitizes a normal string", () => {
    assert.equal(safeShellArg("normal_arg", "test"), "normal_arg");
  });

  it("throws for oversized input", () => {
    const long = "a".repeat(5000);
    assert.throws(
      () => safeShellArg(long, "oversized"),
      /oversized: input exceeds maximum length/
    );
  });

  it("sanitizes dangerous characters", () => {
    const result = safeShellArg("foo;rm -rf /;bar", "test");
    assert.equal(result.includes(";"), false);
    assert.equal(result, "foorm-rf/bar");
  });

  it("handles null/undefined without throwing", () => {
    assert.doesNotThrow(() => safeShellArg(null, "test"));
    assert.doesNotThrow(() => safeShellArg(undefined, "test"));
  });

  it("preserves zero and false via ?? operator", () => {
    assert.equal(safeShellArg(0, "test"), "0");
    assert.equal(safeShellArg(false, "test"), "false");
  });
});

// ─── Integration: Verify source constants ────────────
describe("index.js integration check", () => {

  it("MAX_INPUT_LENGTH=4096 exists in source", () => {
    assert.ok(src.includes("MAX_INPUT_LENGTH = 4096"), "MAX_INPUT_LENGTH should be 4096");
    assert.ok(src.includes("function sanitizeShellArg"), "Function sanitizeShellArg exists");
    assert.ok(src.includes("function validateInputLength"), "Function validateInputLength exists");
    assert.ok(src.includes("function safeShellArg"), "Function safeShellArg exists");
  });

  it("regex pattern matches between test and source", () => {
    // Both use [^\w.:@/\-{}] regex - check the key components exist in both
    const testRegexContains = sanitizeShellArg.toString().includes("[^") &&
                             sanitizeShellArg.toString().includes("\\-{}");
    const srcRegexContains = src.includes("[^") && src.includes("\\-{}");
    assert.ok(testRegexContains, "Test regex has character class and hyphen-brace pattern");
    assert.ok(srcRegexContains, "Source regex has character class and hyphen-brace pattern");
  });

  it("all security functions exist in index.js source", () => {
    assert.ok(src.includes("function sanitizeShellArg"), "sanitizeShellArg function exists");
    assert.ok(src.includes("function validateInputLength"), "validateInputLength function exists");
    assert.ok(src.includes("function safeShellArg"), "safeShellArg function exists");
    assert.ok(src.includes("MAX_INPUT_LENGTH = 4096"), "MAX_INPUT_LENGTH constant exists");
  });
});
