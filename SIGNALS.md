# Signal Handling

Workers should handle following signals:

- **TTIN** : increase number of workers
- **TTOU** : decrease number of workers
- **WINCH** : stop working
- **HUP** : resume working

