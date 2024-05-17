import 'package:restaurante/src/data/dataSource/local/SharedPref.dart';
import 'package:restaurante/src/data/dataSource/remote/services/AreasService.dart';
import 'package:restaurante/src/data/dataSource/remote/services/CategoriesService.dart';
import 'package:restaurante/src/data/dataSource/remote/services/OrdersService.dart';
import 'package:restaurante/src/data/dataSource/remote/services/UsersService.dart';
import 'package:restaurante/src/data/repositories/AreasRepositoryImpl.dart';
import 'package:restaurante/src/data/repositories/AuthRepositoryImpl.dart';
import 'package:restaurante/src/data/dataSource/remote/services/AuthService.dart';
import 'package:restaurante/src/data/repositories/CategoriesRepositoryImpl.dart';
import 'package:restaurante/src/data/repositories/OrdersRepositoryImpl.dart';
import 'package:restaurante/src/data/repositories/UsersRepositoryImpl.dart';
import 'package:restaurante/src/data/dataSource/remote/services/RolesService.dart';
import 'package:restaurante/src/data/repositories/RolesRepositoryImpl.dart';
import 'package:restaurante/src/domain/models/AuthResponse.dart';
import 'package:restaurante/src/domain/repositories/AreasRepository.dart';
import 'package:restaurante/src/domain/repositories/AuthRepository.dart';
import 'package:restaurante/src/domain/repositories/CategoriesRepository.dart';
import 'package:restaurante/src/domain/repositories/OrdersRepository.dart';
import 'package:restaurante/src/domain/repositories/UsersRepository.dart';
import 'package:restaurante/src/domain/repositories/RolesRepository.dart';
import 'package:restaurante/src/domain/useCases/areas/AreasUseCases.dart';
import 'package:restaurante/src/domain/useCases/areas/GetAreasUseCase.dart';
import 'package:restaurante/src/domain/useCases/areas/GetTablesFromAreaUseCase.dart';
import 'package:restaurante/src/domain/useCases/categories/CategoriesUseCases.dart';
import 'package:restaurante/src/domain/useCases/categories/GetCategoriesWithProductsUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/CancelOrderUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/CompleteMultipleOrdersUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/CompleteOrderUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/CreateOrderUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/FindOrderItemsWithCounts.dart';
import 'package:restaurante/src/domain/useCases/orders/GetClosedOrdersUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/GetDeliveryOrdersUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/GetOpenOrdersUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/GetOrderForUpdateUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/GetPrintedOrdersUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/GetSalesReportUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/MarkOrdersAsInDeliveryUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/OrdersUseCases.dart';
import 'package:restaurante/src/domain/useCases/orders/RegisterPaymentUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/RegisterTicketPrintUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/ResetDatabaseUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/RevertMultipleOrdersUseCase%20copy.dart';
import 'package:restaurante/src/domain/useCases/orders/SynchronizeDataUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/UpdateOrderItemPreparationAdvanceStatus.dart';
import 'package:restaurante/src/domain/useCases/orders/UpdateOrderItemStatusUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/UpdateOrderStatusUseCase.dart';
import 'package:restaurante/src/domain/useCases/orders/UpdateOrderUseCase.dart';
import 'package:restaurante/src/domain/useCases/roles/RolesUseCases.dart';
import 'package:restaurante/src/domain/useCases/auth/AuthUseCases.dart';
import 'package:restaurante/src/domain/useCases/auth/GetUserSessionUseCase.dart';
import 'package:restaurante/src/domain/useCases/auth/LoginUseCase.dart';
import 'package:restaurante/src/domain/useCases/auth/LogoutUseCase.dart';
import 'package:restaurante/src/domain/useCases/auth/RegisterUseCase.dart';
import 'package:restaurante/src/domain/useCases/auth/SaveUserSessionUseCase.dart';
import 'package:restaurante/src/domain/useCases/users/UpdateUserUseCase.dart';
import 'package:restaurante/src/domain/useCases/users/UsersUseCases.dart';
import 'package:restaurante/src/domain/useCases/roles/GetRolesUseCase.dart';
import 'package:injectable/injectable.dart';

@module
abstract class AppModule {
  @injectable
  SharedPref get sharedPref => SharedPref();

  @injectable
  Future<String> get token async {
    String token = "";
    final userSession = await sharedPref.read('user');
    if (userSession != null) {
      AuthResponse authResponse = AuthResponse.fromJson(userSession);
      token = authResponse.token;
    }
    return token;
  }

  //SERVICES

  @injectable
  AuthService get authService => AuthService();

  @injectable
  UsersService get usersService => UsersService(token);

  @injectable
  RolesService get rolesService => RolesService();

  AreasService get areasService => AreasService();

  CategoriesService get categoriesService => CategoriesService();

  OrdersService get ordersService => OrdersService();

  //REPOSITORIES

  @injectable
  AuthRepository get authRepository =>
      AuthRepositoryImpl(authService, sharedPref);

  @injectable
  UsersRepository get usersRepository => UsersRepositoryImpl(usersService);

  @injectable
  RolesRepository get rolesRepository => RolesRepositoryImpl(rolesService);

  AreasRepository get areasRepository => AreasRepositoryImpl(areasService);

  CategoriesRepository get categoriesRepository =>
      CategoriesRepositoryImpl(categoriesService);

  OrdersRepository get ordersRepository => OrdersRepositoryImpl(ordersService);

// USE CASES
  @injectable
  AuthUseCases get authUseCases => AuthUseCases(
      login: LoginUseCase(authRepository),
      register: RegisterUseCase(authRepository),
      saveUserSession: SaveUserSessionUseCase(authRepository),
      getUserSession: GetUserSessionUseCase(authRepository),
      logout: LogoutUseCase(authRepository));

  @injectable
  UsersUseCases get usersUseCases =>
      UsersUseCases(updateUser: UpdateUserUseCase(usersRepository));

  @injectable
  RolesUseCases get rolesUseCases =>
      RolesUseCases(getRoles: GetRolesUseCase(rolesRepository));
  @injectable
  AreasUseCases get areasUseCases => AreasUseCases(
      getAreas: GetAreasUseCase(areasRepository),
      getTablesFromArea: GetTablesFromAreaUseCase(areasRepository));

  @injectable
  CategoriesUseCases get categoriesUseCases => CategoriesUseCases(
      getCategoriesWithProducts:
          GetCategoriesWithProductsUseCase(categoriesRepository));

  OrdersUseCases get ordersUseCases => OrdersUseCases(
        createOrder: CreateOrderUseCase(ordersRepository),
        getOpenOrders: GetOpenOrdersUseCase(ordersRepository),
        getClosedOrders: GetClosedOrdersUseCase(ordersRepository),
        getOrderForUpdate: GetOrderForUpdateUseCase(ordersRepository),
        updateOrder: UpdateOrderUseCase(ordersRepository),
        updateOrderStatus: UpdateOrderStatusUseCase(ordersRepository),
        updateOrderItemStatus: UpdateOrderItemStatusUseCase(ordersRepository),
        synchronizeData: SynchronizeDataUseCase(ordersRepository),
        findOrderItemsWithCounts:
            FindOrderItemsWithCountsUseCase(ordersRepository),
        registerPayment: RegisterPaymentUseCase(ordersRepository),
        completeOrder: CompleteOrderUseCase(ordersRepository),
        completeMultipleOrders: CompleteMultipleOrdersUseCase(ordersRepository),
        cancelOrder: CancelOrderUseCase(ordersRepository),
        getDeliveryOrders: GetDeliveryOrdersUseCase(ordersRepository),
        markOrdersAsInDelivery: MarkOrdersAsInDeliveryUseCase(ordersRepository),
        resetDatabase: ResetDatabaseUseCase(ordersRepository),
        getPrintedOrders: GetPrintedOrdersUseCase(ordersRepository),
        registerTicketPrint: RegisterTicketPrintUseCase(ordersRepository),
        revertMultipleOrders: RevertMultipleOrdersUseCase(ordersRepository),
        getSalesReport: GetSalesReportUseCase(ordersRepository),
        updateOrderItemPreparationAdvanceStatus:
            UpdateOrderItemPreparationAdvanceStatusUseCase(ordersRepository),
      );
}
