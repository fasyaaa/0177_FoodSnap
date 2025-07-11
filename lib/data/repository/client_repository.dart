import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:foody/core/constants/api_path.dart';
import 'package:foody/data/models/request/client/client_request_model.dart';
import 'package:foody/data/models/response/client/client_response_model.dart';
import 'package:foody/service/service_http_client.dart';

class ClientRepository {
  final ServiceHttpClient _httpClient;

  ClientRepository(this._httpClient);

  // Create new client (POST /clients)
  Future<Either<String, ClientResponseModel>> createClient(ClientRequestModel model) async {
    try {
      final response = await _httpClient.post(ApiPath.clients, model.toMap());
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 201) {
        final client = ClientResponseModel.fromMap(jsonResponse['data']);
        return Right(client);
      } else {
        return Left(jsonResponse['message'] ?? "Failed to create client");
      }
    } catch (e) {
      return Left("An error occurred while creating client: $e");
    }
  }

  // Get all clients (GET /clients)
  Future<Either<String, List<ClientResponseModel>>> getAllClients() async {
    try {
      final response = await _httpClient.get(ApiPath.clients);
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<ClientResponseModel> clients = (jsonResponse['data'] as List)
            .map((item) => ClientResponseModel.fromMap(item))
            .toList();
        return Right(clients);
      } else {
        return Left(jsonResponse['message'] ?? "Failed to fetch clients");
      }
    } catch (e) {
      return Left("An error occurred while fetching clients: $e");
    }
  }

  // Get single client by ID (GET /clients/{id})
  Future<Either<String, ClientResponseModel>> getClientById(int id) async {
    try {
      final response = await _httpClient.get('${ApiPath.clients}/$id');
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final client = ClientResponseModel.fromMap(jsonResponse['data']);
        return Right(client);
      } else {
        return Left(jsonResponse['message'] ?? "Client not found");
      }
    } catch (e) {
      return Left("An error occurred while fetching client: $e");
    }
  }

  // Update client (PUT /clients/{id})
  Future<Either<String, ClientResponseModel>> updateClient(int id, ClientRequestModel model) async {
    try {
      final response = await _httpClient.put('${ApiPath.clients}/$id', model.toMap());
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        final client = ClientResponseModel.fromMap(jsonResponse['data']);
        return Right(client);
      } else {
        return Left(jsonResponse['message'] ?? "Failed to update client");
      }
    } catch (e) {
      return Left("An error occurred while updating client: $e");
    }
  }

  // Delete client (DELETE /clients/{id})
  Future<Either<String, String>> deleteClient(int id) async {
    try {
      final response = await _httpClient.delete('${ApiPath.clients}/$id');
      final jsonResponse = json.decode(response.body);

      if (response.statusCode == 200) {
        return Right(jsonResponse['message'] ?? "Client deleted successfully");
      } else {
        return Left(jsonResponse['message'] ?? "Failed to delete client");
      }
    } catch (e) {
      return Left("An error occurred while deleting client: $e");
    }
  }
}
