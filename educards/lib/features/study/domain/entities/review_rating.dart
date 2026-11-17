/// Review rating for the SM-2 algorithm.
/// Quality values follow the original SM-2 specification.
enum ReviewRating {
  again(0),
  hard(3),
  good(4),
  easy(5);

  final int quality;
  const ReviewRating(this.quality);
}
