import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../modals/networking.dart';
import '../widgets/subtitle_item_widget.dart';

enum Languages { Arabic, English }

class MoviesScreen extends StatefulWidget {
  @override
  _MoviesScreenState createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  final seasonFocusNode = FocusNode();
  final episodeFocusNode = FocusNode();

  @override
  void dispose() {
    seasonFocusNode.dispose();
    episodeFocusNode.dispose();
    super.dispose();
  }

  bool movieMode = true;
  Languages language = Languages.Arabic;

  String title = '';
  int season = 0;
  int episode = 0;
  String lang = 'ara';

  @override
  Widget build(BuildContext context) {
    List subtitles = Provider.of<SubtitleGetter>(context).subs;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Subtitle Bank'),
        actions: [
          PopupMenuButton(
            icon: Icon(Icons.language),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    Icon(Icons.check,
                        color: language == Languages.Arabic
                            ? Theme.of(context).primaryColor
                            : null),
                    Text('Arabic'),
                  ],
                ),
                value: Languages.Arabic,
              ),
              PopupMenuItem(
                  child: Row(
                    children: [
                      Icon(Icons.check,
                          color: language == Languages.English
                              ? Theme.of(context).primaryColor
                              : null),
                      Text('English'),
                    ],
                  ),
                  value: Languages.English)
            ],
            onSelected: (value) {
              setState(() {
                language = value;
                if (value == Languages.Arabic) {
                  lang = 'ara';
                } else {
                  lang = 'eng';
                }
              });
            },
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child:
                    Text(movieMode ? 'Subs for TV Shows' : 'Subs for Movies'),
                value: 0,
              ),
            ],
            onSelected: (value) {
              setState(() {
                movieMode = !movieMode;
                formKey.currentState.reset();
              });
              Provider.of<SubtitleGetter>(context, listen: false).subs = [];
            },
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Container(
          width: double.infinity,
          child: Card(
            margin: const EdgeInsets.all(15),
            color: Colors.grey[200],
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        movieMode
                            ? 'Enter your movie\'s name:'
                            : 'Enter your TV Show\'s details:',
                        style: Theme.of(context).textTheme.headline6),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    child: TextFormField(
                      textInputAction: movieMode
                          ? TextInputAction.done
                          : TextInputAction.next,
                      onFieldSubmitted: movieMode
                          ? (_) {
                              FocusScope.of(context).unfocus();
                            }
                          : (_) {
                              FocusScope.of(context)
                                  .requestFocus(seasonFocusNode);
                            },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please Enter the Title';
                        } else
                          return null;
                      },
                      decoration: InputDecoration(
                          labelText:
                              movieMode ? 'Movie\'s name' : 'TV Show\'s name'),
                      onSaved: (value) {
                        title = value;
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  if (!movieMode)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      child: Row(
                        children: [
                          Expanded(
                              child: TextFormField(
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) {
                              FocusScope.of(context)
                                  .requestFocus(episodeFocusNode);
                            },
                            focusNode: seasonFocusNode,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Please Enter the Season Number';
                              else if (int.tryParse(value) == null)
                                return 'Please enter a valid number';
                              else
                                return null;
                            },
                            onSaved: (value) {
                              season = int.parse(value);
                            },
                            decoration:
                                InputDecoration(labelText: 'Season number'),
                          )),
                          SizedBox(
                            width: 60,
                          ),
                          Expanded(
                              child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  focusNode: episodeFocusNode,
                                  validator: (value) {
                                    if (value.isEmpty)
                                      return 'Please Enter the Episode Number';
                                    else if (int.tryParse(value) == null)
                                      return 'Please enter a valid number';
                                    else
                                      return null;
                                  },
                                  onSaved: (value) {
                                    episode = int.parse(value);
                                  },
                                  decoration: InputDecoration(
                                      labelText: 'Episode number')))
                        ],
                      ),
                    ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.teal,
                    ),
                    onPressed: () async {
                      FocusScope.of(context).unfocus();
                      if (formKey.currentState.validate()) {
                        formKey.currentState.save();
                        setState(() {
                          loading = true;
                        });
                        try {
                          if (movieMode) {
                            await Provider.of<SubtitleGetter>(context,
                                    listen: false)
                                .getMovieSubs(title, lang)
                                .then((value) {
                              if (value != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(value)));
                              }
                            });
                          } else {
                            await Provider.of<SubtitleGetter>(context,
                                    listen: false)
                                .getSeriesSubs(title, season.toString(),
                                    episode.toString(), lang)
                                .then((value) {
                              if (value != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(value),
                                  ),
                                );
                              }
                            });
                          }
                          setState(() {
                            loading = false;
                          });
                        } catch (e) {
                          print(e);
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Find Subtitle',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 15),
                    height: 250,
                    child: loading
                        ? SpinKitRing(color: Theme.of(context).primaryColor)
                        : ListView.builder(
                            shrinkWrap: true,
                            itemBuilder: (context, i) {
                              return SubtitleItem(subtitles[i], () {
                                setState(() {
                                  loading = true;
                                });
                              }, () {
                                setState(() {
                                  loading = false;
                                });
                                ScaffoldMessenger.of(
                                        _scaffoldKey.currentContext)
                                    .showSnackBar(SnackBar(
                                        content: Text(
                                            'Subtitle Saved in Downloads!')));
                              });
                            },
                            itemCount: subtitles.length,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
