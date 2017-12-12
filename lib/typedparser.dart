library typedparser;

import 'package:petitparser/petitparser.dart' as petit;

/// Returns a parser that accepts any of the specified characters.
Parser<String> anyOf(String chars, [String message]) =>
    new Parser(petit.anyOf(chars, message));

/// Returns a parser that accepts a specific character only.
Parser<String> char(Object v, [String message]) =>
    new Parser(petit.char(v, message));

/// Returns a parser that accepts any digit character.
Parser<String> digit([String message = 'digit expected']) =>
    new Parser(petit.digit(message));

/// Returns a parser that accepts any letter character.
Parser<String> letter([String message = 'letter expected']) =>
    new Parser(petit.letter(message));

/// Returns a parser that accepts any lowercase character.
Parser<String> lowercase([String message = 'lowercase letter expected']) =>
    new Parser(petit.lowercase(message));

/// Returns a parser that accepts none of the specified characters.
Parser<String> noneOf(String chars, [String message]) =>
  new Parser(petit.noneOf(chars, message));

/// Returns a parser that accepts the given character class pattern.
Parser<String> pattern(String element, [String message]) =>
    new Parser(petit.pattern(element, message));

/// Returns a parser that accepts any character in the range
/// between [start] and [stop].
Parser<String> range(Object start, Object stop, [String message]) =>
    new Parser(petit.range(start, stop, message));

/// Returns a parser that accepts any uppercase character.
Parser<String> uppercase([String message = 'uppercase letter expected']) =>
  new Parser(petit.uppercase(message));

/// Returns a parser that accepts any whitespace character.
Parser<String> whitespace([String message = 'whitespace expected']) =>
    new Parser(petit.whitespace(message));

/// Returns a parser that accepts any word character.
Parser<String> word([String message = 'letter or digit expected']) =>
    new Parser(petit.word(message));

/// Returns a parser that accepts any input element.
Parser<String> any([String message = 'input expected']) =>
    new Parser(petit.any(message));

  /// Returns a parser that accepts the string [element].
Parser<String> string(String element, [String message]) =>
    new Parser(petit.string(element, message));

/// Returns a parser that accepts the string [element] ignoring the case.
Parser<String> stringIgnoreCase(String element, [String message]) =>
    new Parser(petit.stringIgnoreCase(element, message));

/// Returns a parser that consumes nothing and succeeds.
Parser<T> epsilon<T>([T result]) => new Parser(petit.epsilon(result));

/// Returns a parser that consumes nothing and fails.
Parser<T> failure<T>([String message]) => new Parser(petit.failure(message));

/// Returns a parser that is not defined, but that can be set at a later
/// point in time.
SettableParser undefined([String message = 'undefined parser']) {
  return failure(message).settable();
}

/// A parser that is not defined, but that can be set at a later
/// point in time.
class SettableParser<T> extends Parser<T> {

  SettableParser(petit.Parser pParser) : super(pParser);

  /// Sets the receiver to delegate to [parser].
  void set(Parser<T> parser) => _parser.replace(_parser.children[0], parser._parser);

}

/// Returns a parser that consumes the sequence of [parsers] and produces a list
/// with elements of type [T]
ListParser<T> sequenceOf<T>(Iterable<Parser<T>> parsers) {
  return new ListParser(parsers.map((p)=>p._parser).reduce((a,b)=>a&b));
}

/// Returns a parser that consumes any of the strings in [values] and produces
/// the index of the consumed string.
Parser<int> enumIndex(List<String> values, {bool ignoreCase: true}) => values
    .map((k)=>(ignoreCase ? stringIgnoreCase(k) : string(k)).map((_)=>values.indexOf(k)))
    .reduce((a,b)=>a.or(b));

/// Returns a parser that consumes a positive integer number.
Parser<int> positiveInteger() => digit().plus().flatten().map(int.parse);

/// Returns a parser that consumes the `+` or `-` sign and produces `+1` or `-1`.
Parser<int> sign() => enumIndex(["-","+"]).map((v)=>v*2-1);

/// Returns a parser that consumes a positive or negative integer number.
Parser<int> integer() =>
    sign().succeededBy(whitespace().star()).optional(1).seq(positiveInteger(), (int a,int b)=>a*b);

/// Returns a parser that consumes a positive or negative integer number with a
/// required sign symbol.
Parser<int> signedInteger() =>
    sign().succeededBy(whitespace().star()).seq(positiveInteger(), (int a,int b)=>a*b);


/// A typed parser takes strings as input and produces objects of type [T].
///
/// This class wraps a petitparser Parser instance.
class Parser<T> {

  final petit.Parser _parser;

  /// Creates a new parser based on a petitparser Parser instance.
  Parser(this._parser);

  Parser<S> cast<S>() => new Parser(_parser);

  /// Returns the parse result of the [input].
  Result<T> parse(String input) => new Result(_parser.parse(input));

  /// Tests if the [input] can be successfully parsed.
  bool accept(input) => _parser.accept(input);

  /// Returns a list of all successful overlapping parses of the [input].
  Iterable<T> matches(input) => _parser.matches(input);

  /// Returns a list of all successful non-overlapping parses of the input.
  Iterable matchesSkipping(input) => _parser.matchesSkipping(input);

  /// Returns new parser that accepts the receiver, if possible. The resulting
  /// parser returns the result of the receiver, or `null` if not applicable.
  /// The returned value can be provided as an optional argument [otherwise].
  Parser<T> optional([T otherwise]) => new Parser(_parser.optional(otherwise));

  /// Returns a parser that accepts the receiver zero or more times. The
  /// resulting parser returns a list of the parse results of the receiver.
  ListParser<T> star() => new ListParser(_parser.star());

  /// Returns a parser that parses the receiver zero or more times until it
  /// reaches a [limit]. This is a greedy non-blind implementation of the
  /// [Parser.star] operator. The [limit] is not consumed.
  ListParser<T> starGreedy(Parser limit) => new ListParser(_parser.starGreedy(limit._parser));

  /// Returns a parser that parses the receiver zero or more times until it
  /// reaches a [limit]. This is a lazy non-blind implementation of the
  /// [Parser.star] operator. The [limit] is not consumed.
  ListParser<T> starLazy(Parser limit) => new ListParser(_parser.starLazy(limit._parser));

  /// Returns a parser that accepts the receiver one or more times. The
  /// resulting parser returns a list of the parse results of the receiver.
  ListParser<T> plus() => new ListParser(_parser.plus());

  /// Returns a parser that parses the receiver one or more times until it
  /// reaches [limit]. This is a greedy non-blind implementation of the
  /// [Parser.plus] operator. The [limit] is not consumed.
  ListParser<T> plusGreedy(Parser limit) => new ListParser(_parser.plusLazy(limit._parser));

  /// Returns a parser that parses the receiver one or more times until it
  /// reaches a [limit]. This is a lazy non-blind implementation of the
  /// [Parser.plus] operator. The [limit] is not consumed.
  ListParser<T> plusLazy(Parser limit) => new ListParser(_parser.plusLazy(limit._parser));

  /// Returns a parser that accepts the receiver between [min] and [max] times.
  /// The resulting parser returns a list of the parse results of the receiver.
  ListParser<T> repeat(int min, int max) => new ListParser(_parser.repeat(min, max));

  /// Returns a parser that parses the receiver at least [min] and at most [max]
  /// times until it reaches a [limit]. This is a greedy non-blind implementation of
  /// the [Parser.repeat] operator. The [limit] is not consumed.
  ListParser<T> repeatGreedy(Parser limit, int min, int max) => new ListParser(_parser.repeatGreedy(limit._parser, min, max));

  /// Returns a parser that parses the receiver at least [min] and at most [max]
  /// times until it reaches a [limit]. This is a lazy non-blind implementation of
  /// the [Parser.repeat] operator. The [limit] is not consumed.
  ListParser<T> repeatLazy(Parser limit, int min, int max) => new ListParser(_parser.repeatLazy(limit._parser, min, max));

  /// Returns a parser that accepts the receiver exactly [count] times. The
  /// resulting parser returns a list of the parse results of the receiver.
  ListParser<T> times(int count) => new ListParser(_parser.times(count));

  /// Returns a parser that accepts the receiver followed by [other] and
  /// produces an object of type [S] by combining the object produced by `this`
  /// and `other` using the function [combiner].
  Parser<S> seq<S,W>(Parser<W> other, S Function(T,W) combiner) =>
      new Parser(_parser.seq(other._parser).map((l)=>combiner(l[0],l[1])));

  /// Returns a parser that accepts the receiver or [other]. The resulting
  /// parser returns the parse result of the receiver, if the receiver fails
  /// it returns the parse result of [other] (exclusive ordered choice).
  Parser<T> or(Parser<T> other) => new Parser(_parser.or(other._parser));

  /// Convenience operator returning a parser that accepts the receiver or
  /// [other]. See [Parser.or] for details.
  Parser<T> operator |(Parser<T> other) => this.or(other);

  /// Returns a parser that accepts the sequence of `this` and `other` and
  /// produces the consumed input as String.
  Parser<String> operator &(Parser other) => new Parser(_parser&other._parser).flatten();

  /// Returns a parser (logical and-predicate) that succeeds whenever the
  /// receiver does, but never consumes input.
  Parser<T> and() => new Parser(_parser.and());

  /// Returns a parser (logical not-predicate) that succeeds whenever the
  /// receiver fails, but never consumes input.
  Parser<Null> not([String message]) => new Parser(_parser.not(message));

  /// Returns a parser that consumes any input token (character), but the
  /// receiver.
  Parser<String> neg([String message]) => new Parser(_parser.neg(message));

  /// Returns a parser that discards the result of the receiver, and returns
  /// a sub-string of the consumed range in the string/list being parsed.
  Parser<String> flatten() => new Parser(_parser.flatten());

  /// Returns a parser that returns a [Token]. The token carries the parsed
  /// value of the receiver [Token.value], as well as the consumed input
  /// [Token.input] from [Token.start] to [Token.stop] of the input being
  /// parsed.
  ///
  /// For example, the parser `letter().plus().token()` returns the token
  /// `Token[start: 0, stop: 3, value: abc]` for the input `'abc'`.
  Parser<Token<T>> token() => new Parser(_parser.token()).map((v)=>new Token(v));

  /// Returns a parser that consumes input before and after the receiver,
  /// discards the excess input and only returns returns the result of the
  /// receiver. The optional argument is a parser that consumes the excess
  /// input. By default `whitespace()` is used. Up to two arguments can be
  /// provided to have different parsers on the [left] and [right] side.
  Parser<T> trim([Parser left, Parser right]) =>
      new Parser(_parser.trim(left?._parser, right?._parser));

  /// Returns a parser that succeeds only if the receiver consumes the complete
  /// input, otherwise return a failure with the optional [message].
  Parser<T> end([String message = 'end of input expected']) =>
      new Parser(_parser.end(message));

  /// Returns a parser that points to the receiver, but can be changed to point
  /// to something else at a later point in time.
  SettableParser settable() => new SettableParser(_parser);

  /// Returns a parser that maps the produced output of `this` parser to an
  /// object of type [S].
  Parser<S> map<S>(S Function(T) mapper) => new Parser(_parser.map(mapper));

  /// Returns a parser that consumes the receiver one or more times separated
  /// by the [separator] parser.
  ListParser<T> separatedBy(Parser separator, {optionalSeparatorAtEnd: true}) =>
      new ListParser(_parser.separatedBy(separator._parser,
          includeSeparators: false, optionalSeparatorAtEnd: optionalSeparatorAtEnd));

  /// Recursively tests for structural equality of two parsers.
  bool isEqualTo(Parser other) => _parser.isEqualTo(other._parser);

  /// Returns a parser that consumes and discards input before this receiver.
  Parser<T> precededBy(Parser left) => left.seq(this, (a,b)=>b);

  /// Returns a parser that consumes and discards input after this receiver.
  Parser<T> succeededBy(Parser right) => this.seq(right, (a,b)=>a);

  /// Returns a parser that consumes and discards input before and after this
  /// receiver.
  Parser<T> surroundedBy(Parser left, [Parser right]) =>
      precededBy(left).succeededBy(right ?? left);

  /// Returns a parser that consumes the sequence of `this` and the parser
  /// returned by the mapper function.
  Parser<S> mapParser<S>(Parser<S> Function(T) mapper) {
    var followedBy = petit.undefined();
    return map((v) {
      var p = mapper(v);
      followedBy.set(p._parser);
      return v;
    }).seq(new Parser(followedBy), (a,b)=>b);
  }






}


class ListParser<T> extends Parser<List<T>> {

  ListParser(petit.Parser parser) : super(parser);

  /// Returns a parser that transform a successful parse result by returning
  /// the element at [index] of a list. A negative index can be used to access
  /// the elements from the back of the list.
  Parser<T> pick(int index) => new Parser(_parser.pick(index));

  /// Returns a parser that transforms a successful parse result by returning
  /// the permuted elements at [indexes] of a list. Negative indexes can be
  /// used to access the elements from the back of the list.
  ///
  /// For example, the parser `letter().star().permute([0, -1])` returns the
  /// first and last letter parsed. For the input `'abc'` it returns
  /// `['a', 'c']`.
  ListParser<T> permute(List<int> indexes) => new ListParser(_parser.permute(indexes));


  @override
  ListParser<T> trim([Parser left, Parser right]) => new ListParser(super.trim(left,right)._parser);

  @override
  ListParser<T> precededBy(Parser left) => new ListParser(super.precededBy(left)._parser);

  @override
  ListParser<T> succeededBy(Parser right) => new ListParser(super.succeededBy(right)._parser);

  @override
  ListParser<T> surroundedBy(Parser left, [Parser right]) =>
      new ListParser(super.surroundedBy(left,right)._parser);


}

/// Wraps a petitparser parse Result.
class Result<T> {
  final petit.Result _result;

  Result(this._result);

  /// Returns [true] if this result indicates a parse success.
  bool get isSuccess => _result.isSuccess;

  /// Returns [true] if this result indicates a parse failure.
  bool get isFailure => _result.isFailure;

  /// Returns the parse result of the current context.
  T get value => _result.value;

  /// Returns the parse message of the current context.
  String get message => _result.message;

}

/// A token represents a parsed part of the input stream.
///
/// The token holds the resulting value of the input, the input buffer,
/// and the start and stop position in the input buffer. It provides many
/// convenience methods to access the state of the token.
class Token<T> {
  final petit.Token _token;

  const Token(this._token);

  /// The parsed value of the token.
  T get value => _token.value;

  /// The parsed buffer of the token.
  get buffer => _token.buffer;

  /// The start position of the token in the buffer.
  int get start => _token.start;

  /// The stop position of the token in the buffer.
  int get stop => _token.stop;

  /// The consumed input of the token.
  get input => _token.input;

  /// The length of the token.
  int get length => _token.length;

  /// The line number of the token (only works for [String] buffers).
  int get line => _token.line;

  /// The column number of this token (only works for [String] buffers).
  int get column => _token.column;

  @override
  String toString() => _token.toString();

  @override
  bool operator ==(other) {
    return other is Token && _token == other._token;
  }

  @override
  int get hashCode => _token.hashCode;

}

