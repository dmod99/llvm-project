//===- DestinationStyleOpInterface.cpp -- Destination style ops -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/Interfaces/DestinationStyleOpInterface.h"

using namespace mlir;

namespace mlir {
#include "mlir/Interfaces/DestinationStyleOpInterface.cpp.inc"
} // namespace mlir

OpOperandVector::operator SmallVector<Value>() {
  SmallVector<Value> result;
  result.reserve(this->size());
  llvm::transform(*this, std::back_inserter(result),
                  [](OpOperand *opOperand) { return opOperand->get(); });
  return result;
}

LogicalResult detail::verifyDestinationStyleOpInterface(Operation *op) {
  DestinationStyleOpInterface dstStyleOp =
      cast<DestinationStyleOpInterface>(op);

  SmallVector<OpOperand *> outputBufferOperands, outputTensorOperands;
  for (OpOperand *operand : dstStyleOp.getDpsInitOperands()) {
    Type type = operand->get().getType();
    if (isa<MemRefType>(type)) {
      outputBufferOperands.push_back(operand);
    } else if (isa<RankedTensorType>(type)) {
      outputTensorOperands.push_back(operand);
    } else {
      return op->emitOpError("expected that operand #")
             << operand->getOperandNumber()
             << " is a ranked tensor or a ranked memref";
    }
  }

  // Expect at least one output operand.
  int64_t numInputs = dstStyleOp.getNumDpsInputs();
  int64_t numInits = dstStyleOp.getNumDpsInits();
  if (numInits == 0)
    return op->emitOpError("expected at least one output operand");
  if (failed(OpTrait::impl::verifyNOperands(op, numInputs + numInits)))
    return failure();
  // Verify the number of results matches the number of output tensors.
  if (op->getNumResults() != outputTensorOperands.size())
    return op->emitOpError("expected the number of results (")
           << op->getNumResults()
           << ") to be equal to the number of output tensors ("
           << outputTensorOperands.size() << ")";

  for (OpOperand *opOperand : outputTensorOperands) {
    OpResult result = dstStyleOp.getTiedOpResult(opOperand);
    if (result.getType() != opOperand->get().getType())
      return op->emitOpError("expected type of operand #")
             << opOperand->getOperandNumber() << " ("
             << opOperand->get().getType() << ")"
             << " to match type of corresponding result (" << result.getType()
             << ")";
  }
  return success();
}
