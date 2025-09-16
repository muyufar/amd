class BookModel {
  final int id;
  final String title;
  final String author;
  final String coverUrl;
  final String slug;
  final String sinopsis;
  final String category;

  BookModel(
      {required this.id,
      required this.title,
      required this.author, 
      required this.coverUrl,
      required this.slug,
      required this.sinopsis,
      required this.category});
}
