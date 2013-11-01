(function() {
  var changeVtexEnv, getTab, refresh;

  getTab = function(callback) {
    return chrome.tabs.query({
      active: true,
      currentWindow: true
    }, function(tabs) {
      return callback(tabs[0]);
    });
  };

  changeVtexEnv = function(env) {
    return getTab(function(tab) {
      var a, parts, siteName, url;
      a = document.createElement("a");
      a.href = tab.url;
      if (/vtexcommerce/.test(a.hostname)) {
        parts = a.hostname.split(".");
        siteName = (parts[0] === "www" ? parts[1] : parts[0]);
      } else if (jsnomeSite) {
        siteName = jsnomeSite;
      } else {
        siteName = "UNKNOWN";
      }
      url = a.protocol + "//" + siteName + "." + env + ".com.br" + a.pathname + a.search + a.hash;
      return chrome.tabs.update(tab.id, {
        url: url
      });
    });
  };

  $(".env-change").on("click", function() {
    return changeVtexEnv($(this).data("env"));
  });

  refresh = function() {
    return getTab(function(tab) {
      return chrome.cookies.getAll({
        url: tab.url
      }, function(cookies) {
        var cookiesObj, section;
        section = $('#cookies');
        cookiesObj = {};
        cookies.forEach(function(c) {
          return cookiesObj[c.name] = c;
        });
        return section.find('li').each(function(i, el) {
          var id, name, status, _ref;
          name = $(el).data('cookieName');
          id = $(el).attr('id');
          status = section.find('#' + id).find('.status').removeClass('enabled disabled unknown');
          switch ((_ref = cookiesObj[name]) != null ? _ref.value : void 0) {
            case 0:
            case "0":
            case "Value=0":
              return status.text('enabled').addClass('enabled');
            case 1:
            case "1":
            case "Value=1":
              return status.text('disabled').addClass('disabled');
            default:
              return status.text('unknown').addClass('unknown');
          }
        });
      });
    });
  };

  $('#cookies .action').on('click', function() {
    var name, value;
    value = $(this).hasClass('enable') ? 'Value=0' : 'Value=1';
    name = $(this).closest('.cookie').data('cookieName');
    return getTab(function(tab) {
      chrome.cookies.set({
        url: tab.url,
        name: name,
        value: value,
        expirationDate: moment().add('days', 7).unix()
      });
      return refresh();
    });
  });

  $(document).ready(refresh);

}).call(this);
