var changeVtexEnv = function(env){

  chrome.tabs.query({active: true, currentWindow: true}, function (tabs) {
    var tab = tabs[0];
    var a = document.createElement('a');
    var siteName;

    a.href = tab.url;

    if(/vtexcommerce/.test(a.hostname)){
      var parts = a.hostname.split('.');
      siteName = parts[0] === 'www' ? parts[1] : parts[0];
    } else if(jsnomeSite){
      siteName = jsnomeSite;
    } else {
      siteName = 'UNKNOWN';
    }

    var url = a.protocol + '//' + siteName + '.' + env + '.com.br' + a.pathname + a.search + a.hash;

    chrome.tabs.update(tab.id, {url: url})
  })
}

$('.env-change').on('click', function(){
  changeVtexEnv($(this).data('env'));
})