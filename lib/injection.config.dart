// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:restaurante/src/data/dataSource/local/SharedPref.dart' as _i3;
import 'package:restaurante/src/data/dataSource/remote/services/AreasService.dart'
    as _i7;
import 'package:restaurante/src/data/dataSource/remote/services/AuthService.dart'
    as _i4;
import 'package:restaurante/src/data/dataSource/remote/services/CategoriesService.dart'
    as _i8;
import 'package:restaurante/src/data/dataSource/remote/services/OrdersService.dart'
    as _i9;
import 'package:restaurante/src/data/dataSource/remote/services/RolesService.dart'
    as _i6;
import 'package:restaurante/src/data/dataSource/remote/services/UsersService.dart'
    as _i5;
import 'package:restaurante/src/di/AppModule.dart' as _i22;
import 'package:restaurante/src/domain/repositories/AreasRepository.dart'
    as _i13;
import 'package:restaurante/src/domain/repositories/AuthRepository.dart'
    as _i10;
import 'package:restaurante/src/domain/repositories/CategoriesRepository.dart'
    as _i14;
import 'package:restaurante/src/domain/repositories/OrdersRepository.dart'
    as _i15;
import 'package:restaurante/src/domain/repositories/RolesRepository.dart'
    as _i12;
import 'package:restaurante/src/domain/repositories/UsersRepository.dart'
    as _i11;
import 'package:restaurante/src/domain/useCases/areas/AreasUseCases.dart'
    as _i19;
import 'package:restaurante/src/domain/useCases/auth/AuthUseCases.dart' as _i16;
import 'package:restaurante/src/domain/useCases/categories/CategoriesUseCases.dart'
    as _i20;
import 'package:restaurante/src/domain/useCases/orders/OrdersUseCases.dart'
    as _i21;
import 'package:restaurante/src/domain/useCases/roles/RolesUseCases.dart'
    as _i18;
import 'package:restaurante/src/domain/useCases/users/UsersUseCases.dart'
    as _i17;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();
    gh.factory<_i3.SharedPref>(() => appModule.sharedPref);
    gh.factoryAsync<String>(() => appModule.token);
    gh.factory<_i4.AuthService>(() => appModule.authService);
    gh.factory<_i5.UsersService>(() => appModule.usersService);
    gh.factory<_i6.RolesService>(() => appModule.rolesService);
    gh.factory<_i7.AreasService>(() => appModule.areasService);
    gh.factory<_i8.CategoriesService>(() => appModule.categoriesService);
    gh.factory<_i9.OrdersService>(() => appModule.ordersService);
    gh.factory<_i10.AuthRepository>(() => appModule.authRepository);
    gh.factory<_i11.UsersRepository>(() => appModule.usersRepository);
    gh.factory<_i12.RolesRepository>(() => appModule.rolesRepository);
    gh.factory<_i13.AreasRepository>(() => appModule.areasRepository);
    gh.factory<_i14.CategoriesRepository>(() => appModule.categoriesRepository);
    gh.factory<_i15.OrdersRepository>(() => appModule.ordersRepository);
    gh.factory<_i16.AuthUseCases>(() => appModule.authUseCases);
    gh.factory<_i17.UsersUseCases>(() => appModule.usersUseCases);
    gh.factory<_i18.RolesUseCases>(() => appModule.rolesUseCases);
    gh.factory<_i19.AreasUseCases>(() => appModule.areasUseCases);
    gh.factory<_i20.CategoriesUseCases>(() => appModule.categoriesUseCases);
    gh.factory<_i21.OrdersUseCases>(() => appModule.ordersUseCases);
    return this;
  }
}

class _$AppModule extends _i22.AppModule {}
