# QQPercentDrivenInteractiveTransition

`QQPercentDrivenInteractiveTransition` is a drop-in replacement for `UIPercentDrivenInteractiveTransition` for use in custom container view controllers.

Why do you need it? Because Apples own `UIPercentDrivenInteractiveTransition` calls undocumented methods on your custom `UIViewControllerContextTransitioning` objects.

Note that this class can be used with UIKits standard container view controllers such as `UINavigationController`, `UITabBarController` and also for presenting modal view controllers.

