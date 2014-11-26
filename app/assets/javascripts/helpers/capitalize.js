Handlebars.registerHelper('capitalize', function(str) {
  if (str) {
    return str.charAt(0).toUpperCase() + str.slice(1);
  } else {
    return str;
  }
});