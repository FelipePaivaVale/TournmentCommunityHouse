document.addEventListener('DOMContentLoaded', function() {
  var loadMoreBtn = document.getElementById('load-more-btn');
  var matchesContainer = document.getElementById('matches-container');
  var loadingSpinner = document.getElementById('loading-spinner');

  if (loadMoreBtn) {
    loadMoreBtn.addEventListener('click', function() {
      var puuid = this.dataset.puuid;
      var offset = parseInt(this.dataset.offset, 10) || 0;

      loadMoreBtn.style.display = 'none';
      if (loadingSpinner) {
        loadingSpinner.style.display = 'block';
      }

      fetch('/load_more_matches?puuid=' + encodeURIComponent(puuid) + '&offset=' + offset, {
        headers: {
          'Accept': 'text/html',
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
        .then(function(response) { return response.text(); })
        .then(function(html) {
          if (matchesContainer) {
            matchesContainer.insertAdjacentHTML('beforeend', html);
          }
          loadMoreBtn.dataset.offset = offset + 10;
          if (loadingSpinner) {
            loadingSpinner.style.display = 'none';
          }
          loadMoreBtn.style.display = 'inline-block';
        })
        .catch(function(error) {
          console.error('Error loading more matches:', error);
          if (loadingSpinner) {
            loadingSpinner.style.display = 'none';
          }
          loadMoreBtn.style.display = 'inline-block';
          alert('Erro ao carregar mais partidas');
        });
    });
  }
});
