extension MapExtensions<K, V> on Map<K, V> {
  Map<K, V> put(K key, V value) {
    update(key, (_) => value,ifAbsent: () => value);
    return this;
  }

  Map<K,V> clone(){
    return Map.from(this);
  }
}