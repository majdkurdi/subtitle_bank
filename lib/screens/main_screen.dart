import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../modals/networking.dart';
import '../widgets/subtitle_item_widget.dart';

enum Languages { Arabic, English, French, Turkish, German, Russian }

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

  Map<Languages, String> langKey = {
    Languages.Arabic: 'ara',
    Languages.English: 'eng',
    Languages.French: 'fre',
    Languages.German: 'ger',
    Languages.Turkish: 'tur',
    Languages.Russian: 'rus'
  };
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      language = Languages.values.firstWhere(
        (element) => element.toString() == pref.get('lang').toString(),
        orElse: () => Languages.Arabic,
      );
      lang = langKey[language];
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    seasonFocusNode.dispose();
    episodeFocusNode.dispose();
    super.dispose();
  }

  bool movieMode = true;
  Languages language;

  String title = '';
  int season = 0;
  int episode = 0;
  String lang;

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
            itemBuilder: (context) => Languages.values
                .map(
                  (e) => PopupMenuItem<Languages>(
                    child: Row(
                      children: [
                        if (language == e)
                          Icon(Icons.check,
                              color: Theme.of(context).primaryColor),
                        Text(describeEnum(e))
                      ],
                    ),
                    value: e,
                  ),
                )
                .toList(),
            onSelected: (value) async {
              setState(() {
                language = value;
                lang = langKey[value];
              });
              SharedPreferences pref = await SharedPreferences.getInstance();
              pref.setString('lang', language.toString());
            },
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child:
                    Text(movieMode ? 'Subs for TV Shows' : 'Subs for Movies'),
                value: 0,
              ),
            ],
            onSelected: (value) async {
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
        child: Stack(children: [
          SingleChildScrollView(
            child: LogoImage(),
          ),
          Opacity(
            opacity: 0.8,
            child: Card(
                margin: const EdgeInsets.all(15),
                color: Colors.grey[200],
                child: Container(
                  height: (MediaQuery.of(context).size.height - 110),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              movieMode
                                  ? 'Enter your movie\'s name:'
                                  : 'Enter your TV Show\'s details:',
                              style: Theme.of(context).textTheme.headline6),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 15),
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
                                labelText: movieMode
                                    ? 'Movie\'s name'
                                    : 'TV Show\'s name'),
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
                                  decoration: InputDecoration(
                                      labelText: 'Season number'),
                                )),
                                SizedBox(width: 60),
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
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(primary: Colors.teal),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            if (formKey.currentState.validate()) {
                              formKey.currentState.save();
                              setState(() {
                                loading = true;
                              });
                              if (movieMode) {
                                await Provider.of<SubtitleGetter>(context,
                                        listen: false)
                                    .getMovieSubs(title, lang)
                                    .then((value) {
                                  if (value != null) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(value),
                                      ),
                                    );
                                  }
                                });
                              } else {
                                await Provider.of<SubtitleGetter>(context,
                                        listen: false)
                                    .getSeriesSubs(title, season.toString(),
                                        episode.toString(), lang)
                                    .then((value) {
                                  if (value != null) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
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
                          margin:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 15),
                          child: loading
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: 20, bottom: 40),
                                  child: SpinKitRing(
                                      color: Theme.of(context).primaryColor),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    return SubtitleItem(subtitles[i], () {
                                      setState(() {
                                        loading = true;
                                      });
                                    }, (bool done) {
                                      setState(() {
                                        loading = false;
                                      });
                                      if (done) {
                                        ScaffoldMessenger.of(
                                                _scaffoldKey.currentContext)
                                            .hideCurrentSnackBar();
                                        ScaffoldMessenger.of(
                                                _scaffoldKey.currentContext)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Subtitle Saved in Downloads!')));
                                      }
                                    }, (String message) {
                                      ScaffoldMessenger.of(
                                              _scaffoldKey.currentContext)
                                          .hideCurrentSnackBar();
                                      ScaffoldMessenger.of(
                                              _scaffoldKey.currentContext)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(message),
                                        ),
                                      );
                                    });
                                  },
                                  itemCount: subtitles.length,
                                ),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ]),
      ),
    );
  }
}

class LogoImage extends StatelessWidget {
  const LogoImage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 6),
          child: Hero(
            tag: 'logo',
            child: Container(
              child: Image(
                image: AssetImage('assets/logo.png'),
              ),
            ),
          ),
        ),
      ),
      height: (MediaQuery.of(context).size.height - 100),
    );
  }
}
