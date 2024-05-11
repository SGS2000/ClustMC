#' Buscar el valor de Q
#'
#' @param valor_n Valor entero mayor o igual a 2, correspondiente al número de
#'    repeticiones por tratamiento. Si es igual o superior a 41, toma el valor 40.
#'
#' @param valor_k Valor entero mayor o igual a 3, correspondiente al número de
#'    tratamientos. Si es igual o superior a 41, toma el valor 40.
#'
#' @param valor_alfa Valor equivalente a 0.05 o 0.01, correspondiente al valor
#'    de significación del test. Por defecto toma el valor 0.05.
#'
#' @return Valor tabulado proveniente de la tabla correspondiente a
#'    'valor_alfa' para el número de repeticiones 'valor_n' y el número de
#'    tratamientos 'valor_k.'
#'
#' @noRd
buscar_q <- function(valor_n, valor_k, valor_alfa = 0.05) {
  if (valor_n > 40) {
    valor_n <- 40
  } else if (valor_n < 2) {
    cli::cli_abort("Cada tratamiento debe tener al menos dos observaciones")
  }

  if (valor_k > 40) {
    valor_k <- 40
  } else if (valor_k < 3) {
    cli::cli_abort(paste(
      "Debe haber al menos tres tratamientos, se hallaron",
      valor_k
    ))
  }

  if (valor_alfa == 0.05) {
    valor_q <- dplyr::filter(t95, t95$n == valor_n, t95$k == valor_k)$valor
  } else if (valor_alfa == 0.01) {
    valor_q <- dplyr::filter(t99, t95$n == valor_n, t95$k == valor_k)$valor
  }

  return(valor_q)
}

#' Graficar el dendrograma
#'
#' @param dendrograma Objeto de clase hclust.
#' @param c Valor numérico positivo, correspondiente al valor crítico.
#' @param abline_options Lista con argumentos opcionales para la función
#'    `abline`.
#' @param ... Argumentos opcionales para la función `plot`
#'
#' @noRd
graficar_dendrograma_dgc <- function(dendrograma, c, abline_options, ...) {
  # Si el usuario no especifica rotulos, utiliza algunos por defecto
  args <- list(...)
  plot_labels <- c("main", "sub", "xlab", "ylab")
  plot_args <- list(
    main = "Cluster Dendogram",
    sub = "Las diferencias por debajo de la linea no son significativas",
    xlab = "Grupos",
    ylab = "Distancia"
  )

  for (label in plot_labels) {
    if (label %in% names(args)) {
      plot_args <- plot_args[names(plot_args) != label]
    }
  }

  do.call(graphics::plot, c(list(dendrograma), plot_args, args))

  # Le da un estilo determinado a la linea si el usuario no especifica otro
  if (missing(abline_options)) {
    graphics::abline(h = c, col = "steelblue", lwd = 3, lty = 2)
  } else {
    do.call(graphics::abline, c(list(h = c), abline_options))
  }

  # Alerta si la linea no es visible
  if (c > max(dendrograma$height)) {
    cli::cli_alert_info("Ninguna diferencia fue significativa, la linea podria no mostrarse")
  } else if (c < min(dendrograma$height)) {
    cli::cli_alert_info("Todas las diferencias fueron significativas, la linea podria no mostrarse")
  }
}

#' Test DGC
#'
#' Prueba de Di Rienzo, Guzmán y Casanoves para comparaciones múltiples.
#' Implementa un método basado en clusters para identificar grupos de medias no
#' homogéneas.
#'
#' @param y O bien un modelo (creado con `lm()` o `aov()`) o bien un vector
#'    numerico con los valores de la variable respuesta para cada unidad.
#' @param trt Si `y` es un modelo, corresponde a la columna que indica los
#'    tratamientos. Si `y` es un vector, corresponde a un vector de la misma
#'    longitud que `y` con los tratamientos para cada unidad.
#' @param alpha Valor equivalente a 0.05 o 0.01, correspondiente al nivel
#'    de significación del test. Por defecto toma el valor 0.05.
#' @param show_plot Valor logico indicando si debe graficarse el dendrograma
#'    construido o no.
#' @param console Valor logico indicando si deben imprimirse los resultados en
#'    consola o no.
#' @param abline_options Lista con argumentos opcionales para la linea
#'    del dendograma.
#' @param ... Argumentos opcionales para la funcion `plot()`.
#'
#' @returns Una lista con tres objetos `data.frame`:
#'    \item{estadisticas}{`data.frame` con estadisticas resumen segun tratamiento.}
#'    \item{grupos}{`data.frame` indicando el grupo al que es asignado cada
#'    tratamiento.}
#'    \item{parametros}{`data.frame` con los valores utilizados para el test.
#'    `tratamientos` es el numero total de tratamientos, `alpha` es el nivel de
#'    significación utilizado, `c` es el criterio de corte (indica la altura
#'    de la linea horizontal del dendrograma), `q` es el cuantil 1-alpha de la
#'    distribucion de Q (distancia del nodo raiz) bajo la hipotesis nula y
#'    `SEM` es una estimacion del error estandar de la media.}
#' @export
#'
#' @examples
#' data("PlantGrowth")
#' # Utilizando vectores -------------------------------------------------------
#' pesos <- PlantGrowth$weight
#' tratamientos <- PlantGrowth$group
#' dgc_test(y = pesos, trt = tratamientos, show_plot = FALSE)
#' # Utilizando un modelo ------------------------------------------------------
#' modelo <- lm(pesos ~ tratamientos)
#' dgc_test(y = modelo, trt = "tratamientos", show_plot = FALSE)
#' @references Di Rienzo, J.A., Guzmán, A.W., Casanoves, F. (2002): A multiple
#' comparisons method based on the distribution of the root node distance of a
#' binary tree. J. Agr.Biol. Environ. Stat. 7: 1-14.
#' @author Santiago Garcia Sanchez
dgc_test <- function(y, trt, alpha = 0.05, show_plot = T, console = T,
                     abline_options, ...) {
  # Permite que `y` sea un vector e identifica los grupos
  if (!"aov" %in% class(y) && !"lm" %in% class(y)) {
    y <- stats::aov(y ~ trt)
    grupos <- colnames(y$model)[2]
  } else {
    grupos <- trt
    # `trt` debe ser el nombre de una columna
    if (length(colnames(y$model)[which(colnames(y$model) == grupos)]) != 1) {
      cli::cli_abort(paste0(
        "No se encuentra la columna '", trt,
        "' en `y`"
      ))
    }
  }

  # Identifica las variables por su rol
  datos <- y$model
  colnames(datos)[1] <- "var_y"
  colnames(datos)[which(colnames(datos) == grupos)] <- "tratamiento"

  # Evita errores con R CMD check
  tratamiento <- var_y <- NULL

  # `k` es necesario para obtener `Q`
  datos <- datos %>%
    dplyr::group_by(tratamiento) %>%
    dplyr::summarise(
      r = dplyr::n(),
      media = mean(var_y),
      de = stats::sd(var_y),
      mediana = stats::median(var_y),
      min = min(var_y),
      max = max(var_y)
    )

  k <- nrow(datos)

  # `n` es necesario para obtener `Q`
  if (length(unique(datos$r)) == 1) {
    n <- unique(datos$r)
  } else {
    # Si los grupos son desiguales, se aplica la media armonica
    n <- round(psych::harmonic.mean(datos$r))
  }

  # `alpha` debe tener un valor apropiado para calcular `Q`
  if (alpha != 0.05 & alpha != 0.01) {
    cli::cli_warn(
      paste0("`alpha` debe ser 0.05 o 0.01", ", no '", alpha, "'", ". Se utiliza
                  alpha = 0.05 por defecto.")
    )
    alpha <- 0.05
  }
  valor_q <- buscar_q(n, k, alpha)

  # Se construye la tabla ANOVA para obtener MSE
  MSE <- stats::anova(y)[3][[1]][2]
  valor_c <- valor_q * sqrt(MSE / n)

  # Se construye una matriz con las distancea euclidianas
  matriz_d <- stats::dist(datos$media, method = "euclidean") %>%
    usedist::dist_setNames(datos$tratamiento)

  # Se aplica el enlace promedio para los clusters
  dendrograma <- stats::hclust(matriz_d, method = "average")

  if (show_plot) {
    graficar_dendrograma_dgc(dendrograma, valor_c, abline_options, ...)
  }

  # Listas para return
  estadisticas <- as.data.frame(datos[order(datos$media), ])
  grupos <- procs::proc_sort(as.data.frame(stats::cutree(dendrograma, h = valor_c)))
  colnames(grupos) <- "grupo"
  parametros <- data.frame(
    "tratamientos" = k, "alpha" = alpha,
    "c" = valor_c, "q" = valor_q, "SEM" = sqrt(MSE / n)
  )

  if (console) {
    print(grupos)
    cat("Los tratamientos de un mismo grupo no presentan diferencias significativas\n")
  }

  output <- list("estadisticas" = estadisticas, "grupos" = grupos, "parametros" = parametros)
  invisible(output)
}
