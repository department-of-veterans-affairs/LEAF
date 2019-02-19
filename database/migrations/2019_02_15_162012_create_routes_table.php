<?php

use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Database\Migrations\Migration;

class CreateRoutesTable extends Migration
{
    private function getConn() {
        return Schema::connection('routes');
    }

    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        $this->getConn()->create('routes', function (Blueprint $table) {
            $table->string('name');
            $table->string('portal_db')->nullable(false);
            $table->string('nexus_db')->nullable(false);
            $table->timestamps();

            $table->primary('name');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        $this->getConn()->dropIfExists('routes');
    }
}
