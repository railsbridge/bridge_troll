var fakeServer = _.extend(sinon.fakeServer, {
  requestFor: function (url) {
    return _.findWhere(this.requests, {url: url});
  },

  completeRequest: function (url, body) {
    var request = this.requestFor(url);
    if (!request) {
      throw 'No pending request for ' + url + '. Existing requests: ' + _.pluck(this.requests, 'url');
    }

    request.respond(200, {'Content-Type': 'application/json'}, JSON.stringify(body));
  }
});

function getFixtures() {
  return $('#jasmine-fixtures');
}

beforeEach(function() {
  if (getFixtures().length === 0) {
    $('body').append('<div id="jasmine-fixtures"></div>');
  }
  this.server = fakeServer.create();
  Bridgetroll.modalContainerSelector = '#jasmine-fixtures';
});

afterEach(function () {
  this.server.restore();
  getFixtures().empty();
});
