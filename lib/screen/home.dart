import 'package:crud/modals/config.dart';
import 'package:flutter/material.dart';
import 'package:crud/screen/login.dart';
import 'package:crud/modals/users.dart';
import 'package:http/http.dart' as http;
import 'package:crud/screen/userinfo.dart';
import 'package:crud/screen/userform.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    String accountName = "N/A";
    String accountEmail = "N/A";
    String accountUrl =
        "https://scontent-sin6-3.xx.fbcdn.net/v/t39.30808-6/352554675_931408874636062_4438123377568220651_n.jpg?_nc_cat=106&ccb=1-7&_nc_sid=174925&_nc_eui2=AeGhHdf6wIN2esNnIDus5Rq0xXhGnxY4-TnFeEafFjj5OaHnMs2xP1dwPxXlcph--M6PCKcCqoHfGwJgDlDXztcu&_nc_ohc=Bo8g-vN6W04AX_xj2Bx&_nc_ht=scontent-sin6-3.xx&oh=00_AfBMfVlUHyHR190bEhA7L_HFM0bHJhz9kxxb49Loitmg6g&oe=64F01D57";

    Users user = Configure.login;
    print(user.toJson().toString());
    if (user.id != null) {
      accountName = user.fullname!;
      accountEmail = user.email!;
    }
    return Drawer(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(accountName),
              accountEmail: Text(accountEmail),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(accountUrl),
                backgroundColor: Colors.white,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {
                Navigator.pushNamed(context, Home.rounteName);
              },
            ),
            ListTile(
              leading: Icon(Icons.login),
              title: Text("Login"),
              onTap: () {
                Navigator.pushNamed(context, Login.rounteName);
              },
            )
          ]),
    );
  }
}

class Home extends StatefulWidget {
  static const rounteName = "/";
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget mainBody = Container();
  List<Users> _userList = [];

  Future<void> getUsers() async {
    var url = Uri.http(Configure.server, "users");
    var resp = await http.get(url);
    setState(() {
      _userList = usersFromJson(resp.body);
      mainBody = showUsers();
    });
  }

  Future<void> removeUsers(user) async {
    var url = Uri.http(Configure.server, "users/${user.id}");
    var resp = await http.delete(url);
    print(resp.body);
    return;
  }

  @override
  void initState() {
    super.initState();
    Users user = Configure.login;
    if (user.id != null) {
      getUsers();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          backgroundColor: Colors.blue.shade700,
        ),
        drawer: const SideMenu(),
        body: mainBody,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            String result = await Navigator.push(
                context, MaterialPageRoute(builder: (context) => UserForm()));
            if (result == "refresh") {
              getUsers();
            }
          },
          child: const Icon(Icons.person_add_alt_1),
        ),
      );

  Widget showUsers() {
    return ListView.builder(
        itemCount: _userList.length,
        itemBuilder: (context, index) {
          Users user = _userList[index];
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            child: Card(
              child: ListTile(
                title: Text("${user.fullname}"),
                subtitle: Text("${user.email}"),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserInfo(),
                          settings: RouteSettings(arguments: user)));
                }, //to show info
                trailing: IconButton(
                  onPressed: () async {
                    String result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserForm(),
                            settings: RouteSettings(arguments: user)));
                    if (result == "refresh") {
                      getUsers();
                    }
                  }, //to edit
                  icon: Icon(Icons.edit),
                ),
              ),
            ),
            onDismissed: (direction) {
              removeUsers(user);
            }, //to delete
            background: Container(
              color: Colors.red,
              margin: EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          );
        });
  }
}
