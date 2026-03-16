class Api {
  static const String baseUrl =
      "http://172.20.10.2:3000"; // use your backend IP or localhost
  static const String addPackage = "$baseUrl/api/packages/add";
  static const String getPackages = "$baseUrl/api/packages/";
  static const String updatePackage = "$baseUrl/api/packages/update";
  static const String deletePackage = "$baseUrl/api/packages/delete";
}
