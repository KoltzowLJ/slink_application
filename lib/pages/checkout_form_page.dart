// lib/pages/checkout_form_page.dart

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../service/checkout_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CheckoutFormPage extends StatefulWidget {
  final List<Product> cartItems;
  final double total;

  const CheckoutFormPage({
    super.key,
    required this.cartItems,
    required this.total,
  });

  @override
  _CheckoutFormPageState createState() => _CheckoutFormPageState();
}

class _CheckoutFormPageState extends State<CheckoutFormPage> {
  // Form key and controllers
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();

  // Form state
  String _selectedPaymentMethod = 'credit_card';
  String _orderNotes = '';

  @override
  Widget build(BuildContext context) {
    // Calculate order totals
    double subtotal = widget.total;
    double tax = subtotal * 0.15;
    double finalTotal = subtotal + tax;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              _buildOrderSummaryCard(subtotal, tax, finalTotal),
              const SizedBox(height: 20),

              // Shipping Address Section
              _buildShippingAddressSection(),
              const SizedBox(height: 20),

              // Payment Method Section
              _buildPaymentMethodSection(),
              const SizedBox(height: 20),

              // Order Notes Section
              _buildOrderNotesSection(),
              const SizedBox(height: 20),

              // Place Order Button
              _buildPlaceOrderButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Order Summary Widget
  Widget _buildOrderSummaryCard(
      double subtotal, double tax, double finalTotal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // List of cart items
            ...widget.cartItems.map((item) => ListTile(
                  title: Text(item.name),
                  trailing: Text('R${item.price.toStringAsFixed(2)}'),
                )),
            const Divider(),
            // Order totals
            _buildTotalRow('Subtotal:', subtotal),
            _buildTotalRow('Tax (15%):', tax),
            const Divider(),
            _buildTotalRow('Total:', finalTotal, isBold: true),
          ],
        ),
      ),
    );
  }

  // Helper method for total rows
  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    final textStyle =
        isBold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textStyle),
        Text('R${amount.toStringAsFixed(2)}', style: textStyle),
      ],
    );
  }

  // Shipping Address Form Section
  Widget _buildShippingAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Shipping Address',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildTextField(_streetController, 'Street Address'),
        const SizedBox(height: 10),
        _buildTextField(_cityController, 'City'),
        const SizedBox(height: 10),
        _buildTextField(_provinceController, 'Province'),
        const SizedBox(height: 10),
        _buildTextField(_postalCodeController, 'Postal Code'),
        const SizedBox(height: 10),
        _buildTextField(_phoneController, 'Phone Number'),
      ],
    );
  }

  // Helper method for text fields
  Widget _buildTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  // Payment Method Section
  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedPaymentMethod,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: const [
            DropdownMenuItem(value: 'credit_card', child: Text('Credit Card')),
            DropdownMenuItem(value: 'debit_card', child: Text('Debit Card')),
            DropdownMenuItem(value: 'eft', child: Text('EFT')),
          ],
          onChanged: (String? value) {
            if (value != null) {
              setState(() => _selectedPaymentMethod = value);
            }
          },
        ),
      ],
    );
  }

  // Order Notes Section
  Widget _buildOrderNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Notes (Optional)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextFormField(
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add any special instructions...',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => _orderNotes = value,
        ),
      ],
    );
  }

  // Place Order Button
  Widget _buildPlaceOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue[800],
        ),
        onPressed: _handlePlaceOrder,
        child: const Text('Place Order', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  // Order placement handler
  Future<void> _handlePlaceOrder() async {
    if (_formKey.currentState!.validate()) {
      try {
        final checkoutService = CheckoutService();
        final userId = FirebaseAuth.instance.currentUser?.uid;

        if (userId != null) {
          String formattedAddress =
              '${_streetController.text}, ${_cityController.text}, ${_provinceController.text}, ${_postalCodeController.text}';

          await checkoutService.validateStock(widget.cartItems);
          await checkoutService.createOrder(
            userId,
            widget.cartItems,
            widget.total,
            shippingAddress: formattedAddress,
            paymentMethod: _selectedPaymentMethod,
            orderNotes: _orderNotes,
            phoneNumber: _phoneController.text,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order placed successfully!')),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Clean up controllers
    _streetController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
