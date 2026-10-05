# Reglas de R8 para el build de release (se suman a las de Flutter y a las
# que traen las librerías).

# Room crea sus bases de datos por reflexión con el constructor vacío de la
# clase generada (*_Impl). Sin esta regla R8 lo borra y la app se cierra al
# abrir, cuando el SDK de anuncios inicia WorkManager (mismo caso que Ovun).
-keep class * extends androidx.room.RoomDatabase { <init>(); }
