import { PrismaClient } from "@prisma/client";
import bcrypt from "bcrypt";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Seeding database...");

  // Check if data already exists
  const userCount = await prisma.user.count();
  if (userCount > 0) {
    console.log("✅ Database already seeded");
    return;
  }

  // Seed Conditions
  const conditions = [
    { name: "New", description: "Brand new, unused" },
    { name: "Like New", description: "Minimal signs of use" },
    { name: "Good", description: "Normal wear and tear" },
    { name: "Fair", description: "Noticeable wear" },
    { name: "Poor", description: "Significant damage" },
  ];

  for (const condition of conditions) {
    await prisma.condition.create({ data: condition });
  }
  console.log("✅ Conditions seeded");

  // Seed Qualities
  const qualities = [
    { name: "Original", description: "Original parts and condition" },
    { name: "AAA", description: "High quality aftermarket" },
    { name: "High Copy", description: "Good quality copy" },
    { name: "Copy", description: "Standard copy quality" },
  ];

  for (const quality of qualities) {
    await prisma.quality.create({ data: quality });
  }
  console.log("✅ Qualities seeded");

  // Seed Repair States
  const repairStates = [
    { name: "Received", description: "Repair received", order: 1 },
    { name: "Diagnosed", description: "Issue diagnosed", order: 2 },
    { name: "In Progress", description: "Being repaired", order: 3 },
    { name: "Waiting Parts", description: "Waiting for parts", order: 4 },
    { name: "Completed", description: "Repair completed", order: 5 },
    { name: "Ready for Pickup", description: "Ready for customer", order: 6 },
    { name: "Delivered", description: "Delivered to customer", order: 7 },
  ];

  for (const state of repairStates) {
    await prisma.repairState.create({ data: state });
  }
  console.log("✅ Repair states seeded");

  // Seed Issue Types
  const issueTypes = [
    { name: "Screen Damage", description: "Cracked or broken screen" },
    {
      name: "Battery Issue",
      description: "Battery not charging or draining fast",
    },
    { name: "Water Damage", description: "Device exposed to liquid" },
    { name: "Camera Issue", description: "Camera not working properly" },
    { name: "Speaker/Microphone", description: "Audio issues" },
    { name: "Charging Port", description: "Charging port problems" },
    { name: "Software Issue", description: "Software or OS problems" },
    { name: "Other", description: "Other issues" },
  ];

  for (const issueType of issueTypes) {
    await prisma.issueType.create({ data: issueType });
  }
  console.log("✅ Issue types seeded");

  // Seed Payment Methods
  const paymentMethods = [
    { name: "Cash", description: "Cash payment", feeRate: 0.0 },
    {
      name: "Whish Money",
      description: "Whish money (wallet) payment",
      feeRate: 0.0,
    },
    { name: "Card", description: "Credit/Debit card", feeRate: 0.025 },
    { name: "Bank Transfer", description: "Bank transfer", feeRate: 0.0 },
    {
      name: "Mobile Payment",
      description: "Mobile payment apps",
      feeRate: 0.015,
    },
  ];

  for (const method of paymentMethods) {
    await prisma.paymentMethod.create({ data: method });
  }
  console.log("✅ Payment methods seeded");

  // Create default admin user
  const hashedPassword = await bcrypt.hash("myshop99", 10);
  const tech1HashedPassword = await bcrypt.hash("66897197aA@", 10);
  await prisma.user.create({
    data: {
      username: "khaled",
      email: "khaled@repairshop.com",
      password: hashedPassword,
      role: "admin",
    },
  });

  await prisma.user.create({
    data: {
      username: "admin",
      email: "tech1@repairshop.com",
      password: tech1HashedPassword,
      role: "technician",
    },
  });

  console.log("✅ Admin user created (username: khaled, password: myshop99)");

  // Seed demo customer
  const demoCustomer = await prisma.customer.create({
    data: {
      name: "John Doe",
      phone: "+1234567890",
      email: "john.doe@example.com",
      address: "123 Main St, City, Country",
    },
  });
  console.log("✅ Demo customer created");

  // Seed demo repair
  const receivedState = await prisma.repairState.findFirst({
    where: { name: "Received" },
  });

  if (receivedState) {
    await prisma.repair.create({
      data: {
        repairNumber: "REP-2025-0001",
        customerId: demoCustomer.id,
        deviceBrand: "Apple",
        deviceModel: "iPhone 14 Pro",
        deviceImei: "123456789012345",
        password: "1234",
        problemDescription: "Screen is cracked and not responding to touch",
        diagnosisNotes: "Screen damage detected, digitizer needs replacement",
        priority: "high",
        estimatedCost: 150.0,
        estimatedCompletion: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000), // 7 days from now
        warrantyProvided: true,
        warrantyDays: 90,
        stateId: receivedState.id,
        extraInfo: "Customer wants quick repair",
      },
    });
    console.log("✅ Demo repair created");
  }

  console.log("🎉 Database seeding completed!");

  // Add demo serials (IMEIs) if items and batches exist
  const itemsCount = await prisma.item.count();
  const batchesCount = await prisma.batch.count();

  if (itemsCount > 0 && batchesCount > 0) {
    const item = await prisma.item.findFirst();
    const batch = await prisma.batch.findFirst();

    if (item && batch) {
      try {
        await prisma.serial.create({
          data: {
            imei: `IMEI-${item.id}-1`,
            itemId: item.id,
            batchId: batch.id,
          },
        });
        await prisma.serial.create({
          data: {
            imei: `IMEI-${item.id}-2`,
            itemId: item.id,
            batchId: batch.id,
          },
        });
        console.log("✅ Demo serials created for item and batch");
      } catch (error) {
        console.log("ℹ️  Demo serials already exist or failed to create");
      }
    }
  }
}

main()
  .catch((e) => {
    console.error("❌ Error seeding database:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
